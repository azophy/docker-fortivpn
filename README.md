BASIC ALPINE CONTAINER WITH OPENFORTIVPN
========================================

At work, sometimes I would need to connect to private Fortinet VPN connection for development or deployment purposes. This repo made it possible to create container that would connect itself to those VPN connection.

## Potential Use Case
- as starting point for building services which would connect to Fortinet based VPN
- as a shell which connected to such VPN. This prevent us from connecting our host computer to VPN network, thus preventing some undesired case such as slow connections or blocked websites inside VPN.

## How to use as vpn container

1. Edit and save `example.conf` as `<VPN NAME>.conf`
2. `docker compose build`
3. `VPN_NAME=<VPN NAME> docker compose up`

## Gotchas
- For this container to work, it would need a privileged container. I haven't succeed in using other methods, so you should carefully watch for this danger if you wish to use this container. Reference: https://phoenixnap.com/kb/docker-privileged
- the default process for this container is a `tail -f /dev/null`. So you would not see any log when running it. After your container has been attached, you should good to go.
- When running openfortivpn, you would need to first obtainer the valid cert. One way to obtain it if you dont have one is:
  - run docker-compose by commenting the 'command' section.
  - enter the container shell by running `docker-compose exec app sh`
  - run the openfortivpn client by copying the command from docker-compose.yml without the `--trusted-cert` part. You should see some error like these:

    ```
    INFO:   Closed connection to gateway.
    ERROR:  Gateway certificate validation failed, and the certificate d
    igest is not in the local whitelist. If you trust it, rerun with:
    ERROR:      --trusted-cert xxxxxxsomerandomstringxxxxx                                             
    ERROR:  or add this line to your config file:
    ERROR:      trusted-cert = xxxxxxsomrandomstringxxxxx
    ```
  - copy the `trusted-cert` field into your .env file
  - uncomment the command section in your docker-compose.yml, re-run it. You should good to go

## Exposing/Forwarding other host to outside

1. Create ssh ke pair in container. Use could use this tutorial from Gitlab : https://docs.gitlab.com/ee/ssh/

   ```
   $ docker-compose exec app ssh-keygen -t ed25519 -C "test@example.com"  
   ```
2. Start ssh forwarding

  ```
  $ docker-compose exec app ssh -R 80:<remote ip>:<remote port> localhost.run
  ```

3. Or if you want to forward it to your host network:

  ```
  # find all ip address ranges in your container. for example 172.26.x.x or 172.14.x.x
  $ docker-compose exec app ip addr 

  # in your host, find your local docker bridge with matching ranges
  $ ip addr

  # create a tunnel from your container to you local docker bridge
  $ docker-compose exec app ssh -NR <host port>:<remote ip>:<remote port> <user>@<host ip>

  # then your new tunnel should be accessible from `localhost:<host port>`
  $ curl localhost:<host port>
  ```

