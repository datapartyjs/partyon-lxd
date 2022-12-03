#!/bin/bash

lxc profile create mastodon
lxc stop mastodon-primary
lxc delete mastodon-primary
lxc profile edit mastodon-base < ./profiles/mastodon-base.yaml
lxc launch ubuntu:22.04 mastodon-primary --profile mastodon-base

lxc profile create mastodon-postgresql

lxc stop mastodon-psql
lxc delete mastodon-psql
lxc profile edit mastodon-postgresql < ./profiles/mastodon-postgresql.yaml
lxc launch ubuntu:22.04 mastodon-psql --profile mastodon-postgresql



lxc profile create load-balancer

lxc stop lb0
lxc delete lb0
lxc profile edit load-balancer < ./profiles/load-balancer.yaml
lxc launch ubuntu:22.04 lb0 --profile load-balancer

