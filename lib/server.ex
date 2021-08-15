defmodule Andy.HttpServer do
  @moduledoc """
  A simple HTTP server to handle requests
  """
  
  @doc """
  Starts the server on the given `port` of localhost. (Ports 0-1023 are reserved for OS)
  """
  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    
    IO.puts "\n Listening for connection requestson port #{port}...\n"
    
    accept_loop(listen_socket)
  end
  
  def accept_loop(listen_socket) do
    IO.puts " Waiting to accept a client connection...\n"

    # Suspends (blocks) and waits for a client connection.

    # When a connection is accepted, bind the client_socket to new connection socket
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts " Connection accepted!\n"
    
    # Send response to the client socket
    serve(client_socket)
    
    # Restart loop and wait for the next connection
    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on the `client_socket` and sends a response back over the same socket.
  """
  def serve(client_socket) do
    client_socket
    |> read_request
    |> generate_response
    |> write_response(client_socket)
  end
  
  @doc """
  Receives the request on the `client_socket`.
  """
  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)
    
    IO.puts " Received request:\n"
    IO.puts request
    
    request
  end
  
  @doc """
  Returns a mock HTTP response. Temporary placeholder until handler module is implemented.
  """
  def generate_response(_req) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end
  
  @doc """
  Sends `response` to client socket and closes it
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
    
    IO.puts " Sent response:\n"
    IO.puts response
    
    # Closes the client socket, but keeps the listen_socket open
    :gen_tcp.close(client_socket)
  end
end
