module Hubkit
  # A collection of GitHub events with chainable filters
  class EventCollection < ChainableCollection
    # Put the list of events in reverse chronological order
    # @return [EventCollection] the events in reverse chronological order
    def reverse_chronological
      wrap(
        sort do |a, b|
          Time.parse(b['created_at']) <=> Time.parse(a['created_at'])
        end,
      )
    end

    # Put the list of events in chronological order
    # @return [EventCollection] the events in chronological order
    def chronological
      wrap(
        sort do |a, b|
          Time.parse(a['created_at']) <=> Time.parse(b['created_at'])
        end,
      )
    end

    # Filter to all the events which occur between start_dt and end_date,
    # inclusive
    # @param [Date, DateTime] start_dt the beginning of the included period (inclusive)
    # @param [Date, DateTime] end_date the end of the included period (inclusive)
    # @return [EventCollection] the events falling in the window
    def between(start_dt, end_date)
      wrap(
        @inner.select do |event|
          stamp = Time.parse(event['created_at'])
          stamp >= start_dt && stamp <= end_date
        end,
      )
    end

    # Filter to all events where an issue was labeled with a given label
    # @param [String] label the label to search for
    # @return [EventCollection] a collection containing all events where an
    #   issue was labeled with the given label
    def labeled(label)
      wrap(
        @inner.select do |event|
          event['event'] == 'labeled' &&
            event['label'].name.downcase == label.downcase
        end,
      )
    end

    # Filter to all events where an issue was closed
    # @return [EventCollection] a collection containing all events where an
    #   issue was closed
    def closed
      wrap(@inner.select { |event| event.event == 'closed' })
    end
  end
end
