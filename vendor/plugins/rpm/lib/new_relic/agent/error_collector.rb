
module NewRelic
  module Agent
  class ErrorCollector
    include CollectionHelper
    
    # Defined the methods that need to be stubbed out when the
    # agent is disabled
    module Shim #:nodoc:
      def notice_error(*args); end
    end
    
    MAX_ERROR_QUEUE_LENGTH = 20 unless defined? MAX_ERROR_QUEUE_LENGTH
    
    attr_accessor :enabled
    
    def initialize
      @errors = []
      # lookup of exception class names to ignore.  Hash for fast access
      @ignore = {}
      @ignore_filter = nil

      config = NewRelic::Control.instance.fetch('error_collector', {})
      
      @enabled = config.fetch('enabled', true)
      @capture_source = config.fetch('capture_source', true)
      
      ignore_errors = config.fetch('ignore_errors', "")
      ignore_errors = ignore_errors.split(",")
      ignore_errors.each { |error| error.strip! } 
      ignore(ignore_errors)
      @lock = Mutex.new
    end
    
    def ignore_error_filter(&block)
      @ignore_filter = block
    end
    
    
    # errors is an array of Exception Class Names
    #
    def ignore(errors)
      errors.each { |error| @ignore[error] = true; log.debug("Ignoring errors of type '#{error}'") }
    end
    
    # Notice the error with the given available options:
    #
    # * :uri => The request path, minus any request params or query string.
    # * :referer => The URI of the referer
    # * :metric => The metric name associated with the transaction
    # * :request_params => Request parameters, already filtered if necessary
    # * :custom_params => Custom parameters
    def notice_error(exception, options={})
      return unless @enabled
      return if @ignore[exception.class.name] 
      if @ignore_filter
        exception = @ignore_filter.call(exception)
        return if exception.nil?
      end

      action_path     = options[:metric] || NewRelic::Agent.instance.stats_engine.scope_name || ''
      filtered_params = options[:request_params] || {}

      NewRelic::Agent.get_stats("Errors/all").increment_count
      return unless NewRelic::Agent.instance.should_send_errors
      
      data = {}
      
      data[:request_params] = normalize_params(options[:request_params]) if NewRelic::Control.instance.capture_params && options[:request_params]

      data[:custom_params] = normalize_params(options[:custom_params]) if options[:custom_params]
      
      data[:request_uri] = options[:uri] || ''
      data[:request_referer] = options[:referer] || ''
      
      data[:rails_root] = NewRelic::Control.instance.root
      
      data[:file_name] = exception.file_name if exception.respond_to?('file_name')
      data[:line_number] = exception.line_number if exception.respond_to?('line_number')
      
      if @capture_source && exception.respond_to?('source_extract')
        data[:source] = exception.source_extract
      end
      
      if exception.respond_to? 'original_exception'
        inside_exception = exception.original_exception
      else
        inside_exception = exception
      end

      data[:stack_trace] = inside_exception ? inside_exception.backtrace : '<no stack trace>'
      
      noticed_error = NewRelic::NoticedError.new(action_path, data, exception)
      
      @lock.synchronize do
        if @errors.length == MAX_ERROR_QUEUE_LENGTH
          log.warn("The error reporting queue has reached #{MAX_ERROR_QUEUE_LENGTH}. The error detail for this and subsequent errors will not be transmitted to RPM until the queued errors have been sent: #{exception.message}")
        else
          @errors << noticed_error
        end
      end
    end
    
    # Get the errors currently queued up.  Unsent errors are left 
    # over from a previous unsuccessful attempt to send them to the server.
    # We first clear out all unsent errors before sending the newly queued errors.
    def harvest_errors(unsent_errors)
      if unsent_errors && !unsent_errors.empty?
        return unsent_errors
      else
        @lock.synchronize do
          errors = @errors
          @errors = []
          return errors
        end
      end
    end
    
    private
    def log
      NewRelic::Control.instance.log
    end
  end
end
end
