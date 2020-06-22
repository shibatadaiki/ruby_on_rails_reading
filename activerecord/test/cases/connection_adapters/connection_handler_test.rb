# frozen_string_literal: true

require "cases/helper"
require "models/person"

module ActiveRecord
  module ConnectionAdapters
    class ConnectionHandlerTest < ActiveRecord::TestCase
      self.use_transactional_tests = false

      fixtures :people

      def setup
        @handler = ConnectionHandler.new
        @owner_name = "ActiveRecord::Base"
        db_config = ActiveRecord::Base.configurations.configs_for(env_name: "arunit", name: "primary")
        @pool = @handler.establish_connection(db_config)
      end

      def test_default_env_fall_back_to_default_env_when_rails_env_or_rack_env_is_empty_string
        original_rails_env = ENV["RAILS_ENV"]
        original_rack_env  = ENV["RACK_ENV"]
        ENV["RAILS_ENV"]   = ENV["RACK_ENV"] = ""

        assert_equal "default_env", ActiveRecord::ConnectionHandling::DEFAULT_ENV.call
      ensure
        ENV["RAILS_ENV"] = original_rails_env
        ENV["RACK_ENV"]  = original_rack_env
      end

      def test_establish_connection_using_3_levels_config
        previous_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "default_env"

        config = {
          "default_env" => {
            "readonly" => { "adapter" => "sqlite3", "database" => "test/db/readonly.sqlite3" },
            "primary"  => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" }
          },
          "another_env" => {
            "readonly" => { "adapter" => "sqlite3", "database" => "test/db/bad-readonly.sqlite3" },
            "primary"  => { "adapter" => "sqlite3", "database" => "test/db/bad-primary.sqlite3" }
          },
          "common" => { "adapter" => "sqlite3", "database" => "test/db/common.sqlite3" }
        }
        @prev_configs, ActiveRecord::Base.configurations = ActiveRecord::Base.configurations, config

        @handler.establish_connection(:common)
        @handler.establish_connection(:primary)
        @handler.establish_connection(:readonly)

        assert_not_nil pool = @handler.retrieve_connection_pool("readonly")
        assert_equal "test/db/readonly.sqlite3", pool.db_config.database

        assert_not_nil pool = @handler.retrieve_connection_pool("primary")
        assert_equal "test/db/primary.sqlite3", pool.db_config.database

        assert_not_nil pool = @handler.retrieve_connection_pool("common")
        assert_equal "test/db/common.sqlite3", pool.db_config.database
      ensure
        ActiveRecord::Base.configurations = @prev_configs
        ENV["RAILS_ENV"] = previous_env
      end

      unless in_memory_db?
        def test_establish_connection_with_primary_works_without_deprecation
          old_config = ActiveRecord::Base.configurations
          config = { "primary" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" } }
          ActiveRecord::Base.configurations = config

          @handler.establish_connection(:primary)

          assert_not_deprecated do
            @handler.retrieve_connection("primary")
            @handler.remove_connection_pool("primary")
          end
        ensure
          ActiveRecord::Base.configurations = old_config
        end

        def test_retrieve_connection_shows_primary_deprecation_warning_when_established_on_active_record_base
          old_config = ActiveRecord::Base.configurations
          config = { "primary" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" } }
          ActiveRecord::Base.configurations = config

          ActiveRecord::Base.establish_connection(:primary)

          assert_deprecated { @handler.retrieve_connection("primary") }
          assert_deprecated { @handler.remove_connection_pool("primary") }
        ensure
          ActiveRecord::Base.configurations = old_config
          ActiveRecord::Base.establish_connection(:arunit)
        end

        def test_establish_connection_using_3_level_config_defaults_to_default_env_primary_db
          previous_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "default_env"

          config = {
            "default_env" => {
              "primary"  => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" },
              "readonly" => { "adapter" => "sqlite3", "database" => "test/db/readonly.sqlite3" }
            },
            "another_env" => {
              "primary"  => { "adapter" => "sqlite3", "database" => "test/db/another-primary.sqlite3" },
              "readonly" => { "adapter" => "sqlite3", "database" => "test/db/another-readonly.sqlite3" }
            }
          }
          @prev_configs, ActiveRecord::Base.configurations = ActiveRecord::Base.configurations, config

          ActiveRecord::Base.establish_connection

          assert_match "test/db/primary.sqlite3", ActiveRecord::Base.connection.pool.db_config.database
        ensure
          ActiveRecord::Base.configurations = @prev_configs
          ENV["RAILS_ENV"] = previous_env
          ActiveRecord::Base.establish_connection(:arunit)
        end

        def test_establish_connection_using_2_level_config_defaults_to_default_env_primary_db
          previous_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "default_env"

          config = {
            "default_env" => {
              "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3"
            },
            "another_env" => {
              "adapter" => "sqlite3", "database" => "test/db/bad-primary.sqlite3"
            }
          }
          @prev_configs, ActiveRecord::Base.configurations = ActiveRecord::Base.configurations, config

          ActiveRecord::Base.establish_connection

          assert_match "test/db/primary.sqlite3", ActiveRecord::Base.connection.pool.db_config.database
        ensure
          ActiveRecord::Base.configurations = @prev_configs
          ENV["RAILS_ENV"] = previous_env
          ActiveRecord::Base.establish_connection(:arunit)
        end

        def test_remove_connection_is_deprecated
          expected = @handler.retrieve_connection_pool(@owner_name).db_config.configuration_hash

          config_hash = assert_deprecated do
            @handler.remove_connection(@owner_name)
          end

          assert_equal expected, config_hash
        ensure
          ActiveRecord::Base.establish_connection(:arunit)
        end
      end

      def test_establish_connection_using_two_level_configurations
        config = { "development" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" } }
        @prev_configs, ActiveRecord::Base.configurations = ActiveRecord::Base.configurations, config

        @handler.establish_connection(:development)

        assert_not_nil pool = @handler.retrieve_connection_pool("development")
        assert_equal "test/db/primary.sqlite3", pool.db_config.database
      ensure
        ActiveRecord::Base.configurations = @prev_configs
      end

      def test_establish_connection_using_top_level_key_in_two_level_config
        config = {
          "development" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" },
          "development_readonly" => { "adapter" => "sqlite3", "database" => "test/db/readonly.sqlite3" }
        }
        @prev_configs, ActiveRecord::Base.configurations = ActiveRecord::Base.configurations, config

        @handler.establish_connection(:development_readonly)

        assert_not_nil pool = @handler.retrieve_connection_pool("development_readonly")
        assert_equal "test/db/readonly.sqlite3", pool.db_config.database
      ensure
        ActiveRecord::Base.configurations = @prev_configs
      end

      def test_symbolized_configurations_assignment
        @prev_configs = ActiveRecord::Base.configurations
        config = {
          development: {
            primary: {
              adapter: "sqlite3",
              database: "test/db/development.sqlite3",
            },
          },
          test: {
            primary: {
              adapter: "sqlite3",
              database: "test/db/test.sqlite3",
            },
          },
        }
        ActiveRecord::Base.configurations = config
        ActiveRecord::Base.configurations.configs_for.each do |db_config|
          assert_instance_of ActiveRecord::DatabaseConfigurations::HashConfig, db_config
          assert_instance_of String, db_config.env_name
          assert_instance_of String, db_config.name

          db_config.configuration_hash.keys.each do |key|
            assert_instance_of Symbol, key
          end
        end
      ensure
        ActiveRecord::Base.configurations = @prev_configs
      end

      def test_retrieve_connection
        assert @handler.retrieve_connection(@owner_name)
      end

      def test_active_connections?
        assert_not_predicate @handler, :active_connections?
        assert @handler.retrieve_connection(@owner_name)
        assert_predicate @handler, :active_connections?
        @handler.clear_active_connections!
        assert_not_predicate @handler, :active_connections?
      end

      def test_retrieve_connection_pool
        assert_not_nil @handler.retrieve_connection_pool(@owner_name)
      end

      def test_retrieve_connection_pool_with_invalid_id
        assert_nil @handler.retrieve_connection_pool("foo")
      end

      def test_connection_pools
        assert_equal([@pool], @handler.connection_pools)
      end

      def test_a_class_using_custom_pool_and_switching_back_to_primary
        klass2 = Class.new(Base) { def self.name; "klass2"; end }

        assert_same klass2.connection, ActiveRecord::Base.connection

        pool = klass2.establish_connection(ActiveRecord::Base.connection_pool.db_config.configuration_hash)
        assert_same klass2.connection, pool.connection
        assert_not_same klass2.connection, ActiveRecord::Base.connection

        klass2.remove_connection

        assert_same klass2.connection, ActiveRecord::Base.connection
      end

      class ApplicationRecord < ActiveRecord::Base
        self.abstract_class = true
      end

      class MyClass < ApplicationRecord
      end

      def test_connection_specification_name_should_fallback_to_parent
        Object.send :const_set, :ApplicationRecord, ApplicationRecord

        klassA = Class.new(Base)
        klassB = Class.new(klassA)
        klassC = Class.new(MyClass)

        assert_equal klassB.connection_specification_name, klassA.connection_specification_name
        assert_equal klassC.connection_specification_name, klassA.connection_specification_name

        assert_equal "ActiveRecord::Base", klassA.connection_specification_name
        assert_equal "ActiveRecord::Base", klassC.connection_specification_name

        klassA.connection_specification_name = "readonly"
        assert_equal "readonly", klassB.connection_specification_name

        ActiveRecord::Base.connection_specification_name = "readonly"
        assert_equal "readonly", klassC.connection_specification_name
      ensure
        Object.send :remove_const, :ApplicationRecord
        ActiveRecord::Base.connection_specification_name = "ActiveRecord::Base"
      end

      def test_remove_connection_should_not_remove_parent
        klass2 = Class.new(Base) { def self.name; "klass2"; end }
        klass2.remove_connection
        assert_not_nil ActiveRecord::Base.connection
        assert_same klass2.connection, ActiveRecord::Base.connection
      end

      def test_default_handlers_are_writing_and_reading
        assert_equal :writing, ActiveRecord::Base.writing_role
        assert_equal :reading, ActiveRecord::Base.reading_role
      end

      if Process.respond_to?(:fork)
        def test_connection_pool_per_pid
          object_id = ActiveRecord::Base.connection.object_id

          rd, wr = IO.pipe
          rd.binmode
          wr.binmode

          pid = fork {
            rd.close
            wr.write Marshal.dump ActiveRecord::Base.connection.object_id
            wr.close
            exit!
          }

          wr.close

          Process.waitpid pid
          assert_not_equal object_id, Marshal.load(rd.read)
          rd.close
        end

        def test_forked_child_doesnt_mangle_parent_connection
          object_id = ActiveRecord::Base.connection.object_id
          assert_predicate ActiveRecord::Base.connection, :active?

          rd, wr = IO.pipe
          rd.binmode
          wr.binmode

          pid = fork {
            rd.close
            if ActiveRecord::Base.connection.active?
              wr.write Marshal.dump ActiveRecord::Base.connection.object_id
            end
            wr.close

            exit # allow finalizers to run
          }

          wr.close

          Process.waitpid pid
          assert_not_equal object_id, Marshal.load(rd.read)
          rd.close

          assert_equal 3, ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM people")
        end

        unless in_memory_db?
          def test_forked_child_recovers_from_disconnected_parent
            object_id = ActiveRecord::Base.connection.object_id
            assert_predicate ActiveRecord::Base.connection, :active?

            rd, wr = IO.pipe
            rd.binmode
            wr.binmode

            outer_pid = fork {
              ActiveRecord::Base.connection.disconnect!

              pid = fork {
                rd.close
                if ActiveRecord::Base.connection.active?
                  pair = [ActiveRecord::Base.connection.object_id,
                          ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM people")]
                  wr.write Marshal.dump pair
                end
                wr.close

                exit # allow finalizers to run
              }

              Process.waitpid pid
            }

            wr.close

            Process.waitpid outer_pid
            child_id, child_count = Marshal.load(rd.read)

            assert_not_equal object_id, child_id
            rd.close

            assert_equal 3, child_count

            # Outer connection is unaffected
            assert_equal 6, ActiveRecord::Base.connection.select_value("SELECT 2 * COUNT(*) FROM people")
          end
        end

        def test_retrieve_connection_pool_copies_schema_cache_from_ancestor_pool
          @pool.schema_cache = @pool.connection.schema_cache
          @pool.schema_cache.add("posts")

          rd, wr = IO.pipe
          rd.binmode
          wr.binmode

          pid = fork {
            rd.close
            pool = @handler.retrieve_connection_pool(@owner_name)
            wr.write Marshal.dump pool.schema_cache.size
            wr.close
            exit!
          }

          wr.close

          Process.waitpid pid
          assert_equal @pool.schema_cache.size, Marshal.load(rd.read)
          rd.close
        end

        def test_pool_from_any_process_for_uses_most_recent_spec
          skip unless current_adapter?(:SQLite3Adapter)

          file = Tempfile.new "lol.sqlite3"

          rd, wr = IO.pipe
          rd.binmode
          wr.binmode

          pid = fork do
            config_hash = ActiveRecord::Base.configurations.configs_for(env_name: "arunit", name: "primary").configuration_hash.merge(database: file.path)
            ActiveRecord::Base.establish_connection(config_hash)

            pid2 = fork do
              wr.write ActiveRecord::Base.connection_db_config.database
              wr.close
            end

            Process.waitpid pid2
          end

          Process.waitpid pid

          wr.close

          assert_equal file.path, rd.read

          rd.close
        ensure
          if file
            file.close
            file.unlink
          end
        end
      end
    end
  end
end
