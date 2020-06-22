# frozen_string_literal: true

require "helper"
require "jobs/callback_job"
require "jobs/abort_before_enqueue_job"

require "active_support/core_ext/object/inclusion"

class CallbacksTest < ActiveSupport::TestCase
  test "perform callbacks" do
    performed_callback_job = CallbackJob.new("A-JOB-ID")
    performed_callback_job.perform_now
    assert "CallbackJob ran before_perform".in? performed_callback_job.history
    assert "CallbackJob ran after_perform".in? performed_callback_job.history
    assert "CallbackJob ran around_perform_start".in? performed_callback_job.history
    assert "CallbackJob ran around_perform_stop".in? performed_callback_job.history
  end

  test "perform return value" do
    job = Class.new(ActiveJob::Base) do
      def perform
        123
      end
    end

    assert_equal(123, job.perform_now)
  end

  test "perform around_callbacks return value" do
    value = nil

    Class.new(ActiveJob::Base) do
      around_perform do |_, block|
        value = block.call
      end

      def perform
        123
      end
    end.perform_now

    assert_equal(123, value)
  end

  test "enqueue callbacks" do
    enqueued_callback_job = CallbackJob.perform_later
    assert "CallbackJob ran before_enqueue".in? enqueued_callback_job.history
    assert "CallbackJob ran after_enqueue".in? enqueued_callback_job.history
    assert "CallbackJob ran around_enqueue_start".in? enqueued_callback_job.history
    assert "CallbackJob ran around_enqueue_stop".in? enqueued_callback_job.history
  end

  test "#enqueue returns false when before_enqueue aborts callback chain and return_false_on_aborted_enqueue = true" do
    prev = ActiveJob::Base.return_false_on_aborted_enqueue
    ActiveJob::Base.return_false_on_aborted_enqueue = true

    ActiveSupport::Deprecation.silence do
      assert_equal false, AbortBeforeEnqueueJob.new.enqueue
    end
  ensure
    ActiveJob::Base.return_false_on_aborted_enqueue = prev
  end

  test "#enqueue returns self when before_enqueue aborts callback chain and return_false_on_aborted_enqueue = false" do
    prev = ActiveJob::Base.return_false_on_aborted_enqueue
    ActiveJob::Base.return_false_on_aborted_enqueue = false
    job = AbortBeforeEnqueueJob.new
    assert_deprecated do
      assert_equal job, job.enqueue
    end
  ensure
    ActiveJob::Base.return_false_on_aborted_enqueue = prev
  end

  test "#enqueue does not run after_enqueue callbacks when skip_after_callbacks_if_terminated is true" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = true
    reload_job
    job = AbortBeforeEnqueueJob.new
    ActiveSupport::Deprecation.silence do
      job.enqueue
    end

    assert_nil(job.flag)
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#enqueue does run after_enqueue callbacks when skip_after_callbacks_if_terminated is false" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = false
    reload_job
    job = AbortBeforeEnqueueJob.new
    assert_deprecated(/`after_enqueue`\/`after_perform` callbacks no longer run/) do
      job.enqueue
    end

    assert_equal("after_enqueue", job.flag)
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#enqueue does not throw a deprecation warning when skip_after_callbacks_if_terminated_is false but job has no after callbacks" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = false

    job = Class.new(ActiveJob::Base) do
      before_enqueue { throw(:abort) }
      self.return_false_on_aborted_enqueue = true
    end.new

    assert_not_deprecated do
      job.enqueue
    end
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#enqueue does not throw a deprecation warning when skip_after_callbacks_if_terminated_is false and job did not throw an abort" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = false

    job = Class.new(ActiveJob::Base) do
      after_enqueue { nil }

      around_enqueue do |_, block|
        block.call
      rescue ArgumentError
        nil
      end

      before_enqueue { raise ArgumentError }
    end

    assert_not_deprecated do
      job.perform_later
    end
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#perform does not run after_perform callbacks when skip_after_callbacks_if_terminated is true" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = true
    reload_job
    job = AbortBeforeEnqueueJob.new
    job.perform_now

    assert_nil(job.flag)
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#perform does run after_perform callbacks when skip_after_callbacks_if_terminated is false" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = false
    reload_job
    job = AbortBeforeEnqueueJob.new
    assert_deprecated(/`after_enqueue`\/`after_perform` callbacks no longer run/) do
      job.perform_now
    end

    assert_equal("after_perform", job.flag)
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#perform does not throw a deprecation warning when skip_after_callbacks_if_terminated_is false but job has no after callbacks" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = false

    job = Class.new(ActiveJob::Base) do
      before_perform { throw(:abort) }
    end

    assert_not_deprecated do
      job.perform_now
    end
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#perform does not throw a deprecation warning when skip_after_callbacks_if_terminated_is false and job did not throw an abort" do
    prev = ActiveJob::Base.skip_after_callbacks_if_terminated
    ActiveJob::Base.skip_after_callbacks_if_terminated = false

    job = Class.new(ActiveJob::Base) do
      after_perform { nil }

      around_perform do |_, block|
        block.call
      rescue ArgumentError
        nil
      end

      before_perform { raise ArgumentError }
    end

    assert_not_deprecated do
      job.perform_now
    end
  ensure
    ActiveJob::Base.skip_after_callbacks_if_terminated = prev
  end

  test "#enqueue returns self when the job was enqueued" do
    job = CallbackJob.new
    assert_equal job, job.enqueue
  end

  private
    def reload_job
      Object.send(:remove_const, :AbortBeforeEnqueueJob)
      $LOADED_FEATURES.delete($LOADED_FEATURES.grep(%r{jobs/abort_before_enqueue_job}).first)
      require "jobs/abort_before_enqueue_job"
    end
end
