# A collection of GitHub events with chainable filters
module Hubkit
  class EventCollection < ChainableCollection
    def reverse_chronological
      wrap(
        sort do |a, b|
          Time.parse(b['created_at']) <=> Time.parse(a['created_at'])
        end,
      )
    end

    def chronological
      wrap(
        sort do |a, b|
          Time.parse(a['created_at']) <=> Time.parse(b['created_at'])
        end,
      )
    end

    def between(start_dt, end_date)
      wrap(
        @inner.select do |event|
          stamp = Time.parse(event['created_at'])
          stamp >= start_dt && stamp <= end_date
        end,
      )
    end

    def labeled(x)
      wrap(
        @inner.select do |event|
          event['event'] == 'labeled' &&
            event['label'].name.downcase == x.downcase
        end,
      )
    end

    def closed
      wrap(@inner.select { |event| event.event == 'closed' })
    end
  end
end
