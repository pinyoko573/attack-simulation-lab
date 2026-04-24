import subprocess

def ping_ip(ip_address: str):
    """
    Pings the given IP address 5 times using subprocess.check_output.

    Args:
        ip_address: The IP address to ping (as a string).
    """

    print(subprocess.check_output("ping -c 5 "+ip_address, stderr=subprocess.STDOUT))