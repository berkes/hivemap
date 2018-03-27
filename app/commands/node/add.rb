module HiveMap
  module Commands
    module Node
      module Add
        # A command handler and commands that can be issued against the system.
        # These form an interface between the web API and the domain model in
        # the aggregate.
        class Command
          attr_reader :payload, :aggregate_id

          def self.build(**args)
            new(**args).tap(&:validate)
          end

          def initialize(params)
            @payload = params.slice(
              :node_id,
              :lat,
              :lon,
              :author_email,
              :contact_details
            )
            @aggregate_id = payload.delete(:node_id)
          end

          def validate
            raise BadRequest, 'node_id is blank' unless aggregate_id
            raise BadRequest, 'lat is blank' unless payload[:lat]
            raise BadRequest, 'lon is blank' unless payload[:lon]
          end
        end

        # A command handler runs the command.
        class CommandHandler
          def initialize(repository: HiveMap.repository)
            @repository = repository
          end

          # Handle loads the aggregate state from the store using the
          # repository, defers to the aggregate to execute the command, and
          # saves off any newly raised events to the store.
          def handle(command)
            aggregate = repository.load(Aggregates::Node, command.aggregate_id)
            aggregate.add(command.payload)
            repository.save(aggregate)
          end

          private

          attr_reader :repository
        end
      end
    end
  end
end
