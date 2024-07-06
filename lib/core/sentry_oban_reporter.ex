defmodule Core.SentryObanReporter do
  require Logger

  def attach do
    :telemetry.attach("oban-errors", [:oban, :job, :exception], &__MODULE__.handle_event/4, [])
  end

  case System.get_env("MIX_ENV") do
    "prod" ->
      def handle_event([:oban, :job, :exception], measure, meta, _) do
        extra =
          meta.job
          |> Map.take([:id, :args, :meta, :queue, :worker])
          |> Map.merge(measure)

        Sentry.capture_exception(meta.reason, stacktrace: meta.stacktrace, extra: extra)
      end

    _ ->
      def handle_event([:oban, :job, :exception], _measure, meta, _) do
        Logger.error(meta.reason)
        Logger.error(meta.stacktrace)
      end
  end
end
