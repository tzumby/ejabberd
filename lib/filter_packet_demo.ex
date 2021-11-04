defmodule FilterPacketDemo do
  # this allow using info, error, etc for logging
  import Ejabberd.Logger
  @behaviour :gen_mod

  def start(host, _opts) do
    info('Starting ejabberd module Filter Packet Demo')
    Ejabberd.Hooks.add(:filter_packet, :global, __ENV__.module, :on_filter_packet, 50)
    :ok
  end

  def stop(host) do
    info('Stopping ejabberd module Filter Packet Demo')
    Ejabberd.Hooks.delete(:filter_packet, :global, __ENV__.module, :on_filter_packet, 50)
    :ok
  end

  def on_filter_packet({from, to, xml = {:xmlel, "message", attributes, children}} = packet) do
    info("Filtering message: #{inspect(packet)}")

    new_children =
      Enum.map(children, fn child ->
        case child do
          {:xmlel, "body", [], [xmlcdata: text]} ->
            {:xmlel, "body", [], [xmlcdata: String.upcase(text)]}

          _ ->
            child
        end
      end)

    {from, to, {:xmlel, "message", attributes, new_children}}
  end

  def on_filter_packet(packet), do: packet
end
