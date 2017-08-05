# concourse-bbr-boshrelease

Backup/Restore Concourse with [BBR](http://www.boshbackuprestore.io/).

## Deploy Concourse BBR

Add `concourse-bbr` in your manifest file that deploys Concourse.

``` yaml
name: concourse

releases:
- name: concourse
  version: 3.3.2
  url: https://bosh.io/d/github.com/concourse/concourse?v=3.3.2
  sha1: 2c876303dc6866afb845e728eab58abae8ff3be2
- name: garden-runc
  version: 1.6.0
  url: https://bosh.io/d/github.com/cloudfoundry/garden-runc-release?v=1.6.0
  sha1: 58fbc64aff303e6d76899441241dd5dacef50cb7
- name: concourse-bbr # <---- Add 
  version: 0.5.0
  url: https://github.com/making/concourse-bbr-boshrelease/releases/download/0.5.0/concourse-bbr-0.5.0.tgz
  sha1: bb4f2c9fd781e32a84fe1386599cfa691adcfeb8

## ....


- name: web
  instances: 1
  vm_type: default
  stemcell: trusty
  azs: [z1]
  networks:
  - name: default
    static_ips: [((internal_ip))]
  jobs:
  - name: atc
    release: concourse
    properties:
      # ...
  - name: atc-lock # <---- Add 
    release: concourse-bbr      
  - name: tsa
    release: concourse
    properties: {}
- name: db
  instances: 1
  vm_type: default
  persistent_disk_type: default
  stemcell: trusty
  azs: [z1]
  networks:
  - name: default
  jobs:
  - name: postgresql
    release: concourse
    properties:
      databases:
      - name: *atc_db
        role: atc
        password: ((postgres_password))
  - name: db-backup # <---- Add 
    release: concourse-bbr

## ....
```

or you can also opsfile as follows:

```
bosh deploy -d concourse concourse.yml -o concoruse-bbr-ops.yml
```

## Backup Concourse with BBR

```
$ bbr deployment -t 192.168.50.6 -u admin -d concourse --ca-cert ~/uaa_ca backup
[bbr] 2017/07/14 18:24:24 INFO - Running pre-checks for backup of concourse...
[bbr] 2017/07/14 18:24:24 INFO - Scripts found:
[bbr] 2017/07/14 18:24:26 INFO - db/d3d811f4-03f1-45c4-9b0f-a77b35664e68/db-backup/backup
[bbr] 2017/07/14 18:24:26 INFO - db/d3d811f4-03f1-45c4-9b0f-a77b35664e68/db-backup/restore
[bbr] 2017/07/14 18:24:29 INFO - Starting backup of concourse...
[bbr] 2017/07/14 18:24:29 INFO - Running pre-backup scripts...
[bbr] 2017/07/14 18:24:29 INFO - Done.
[bbr] 2017/07/14 18:24:29 INFO - Running backup scripts...
[bbr] 2017/07/14 18:24:29 INFO - Backing up db-backup on db/d3d811f4-03f1-45c4-9b0f-a77b35664e68...
[bbr] 2017/07/14 18:24:30 INFO - Done.
[bbr] 2017/07/14 18:24:30 INFO - Running post-backup scripts...
[bbr] 2017/07/14 18:24:30 INFO - Done.
[bbr] 2017/07/14 18:24:30 INFO - Copying backup -- 118M uncompressed -- from db/d3d811f4-03f1-45c4-9b0f-a77b35664e68...
[bbr] 2017/07/14 18:24:31 INFO - Finished copying backup -- from db/d3d811f4-03f1-45c4-9b0f-a77b35664e68...
[bbr] 2017/07/14 18:24:31 INFO - Starting validity checks
[bbr] 2017/07/14 18:24:33 INFO - Finished validity checks
[bbr] 2017/07/14 18:24:33 INFO - Backup created of concourse on 2017-07-14 18:24:33.140126663 +0900 JST
```

`concourse_20170714T092429Z/ ` directory is created.

## Restore Concourse with BBR

```
$ bbr deployment -t 192.168.50.6 -u admin -d concourse --ca-cert ~/uaa_ca restore --artifact-path ./concourse_20170714T092429Z/
[bbr] 2017/07/14 18:26:57 INFO - Starting restore of concourse...
[bbr] 2017/07/14 18:26:59 INFO - db/d3d811f4-03f1-45c4-9b0f-a77b35664e68/db-backup/backup
[bbr] 2017/07/14 18:26:59 INFO - db/d3d811f4-03f1-45c4-9b0f-a77b35664e68/db-backup/restore
[bbr] 2017/07/14 18:27:02 INFO - Copying backup to db/0...
[bbr] 2017/07/14 18:27:04 INFO - Done.
[bbr] 2017/07/14 18:27:04 INFO - Running restore scripts...
[bbr] 2017/07/14 18:27:04 INFO - Restoring db-backup on db/d3d811f4-03f1-45c4-9b0f-a77b35664e68...
[bbr] 2017/07/14 18:27:07 INFO - Done.
[bbr] 2017/07/14 18:27:07 INFO - Completed restore of concourse
```
