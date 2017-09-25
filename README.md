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
  version: 0.5.2
  url: https://github.com/making/concourse-bbr-boshrelease/releases/download/0.5.2/concourse-bbr-0.5.2.tgz
  sha1: 8ddeeec141cdab141b2482ef1507d1ce9fd91875 
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
[bbr] 2017/08/05 16:40:06 INFO - Running pre-checks for backup of concourse...
[bbr] 2017/08/05 16:40:06 INFO - Scripts found:
[bbr] 2017/08/05 16:40:08 INFO - web/e59990aa-2bc8-4958-a563-1346184eef1d/atc-lock/post-backup-unlock
[bbr] 2017/08/05 16:40:08 INFO - web/e59990aa-2bc8-4958-a563-1346184eef1d/atc-lock/pre-backup-lock
[bbr] 2017/08/05 16:40:10 INFO - db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77/db-backup/backup
[bbr] 2017/08/05 16:40:10 INFO - db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77/db-backup/restore
[bbr] 2017/08/05 16:40:11 INFO - Starting backup of concourse...
[bbr] 2017/08/05 16:40:11 INFO - Running pre-backup scripts...
[bbr] 2017/08/05 16:40:11 INFO - Locking atc-lock on web/e59990aa-2bc8-4958-a563-1346184eef1d for backup...
[bbr] 2017/08/05 16:40:11 INFO - Done.
[bbr] 2017/08/05 16:40:11 INFO - Done.
[bbr] 2017/08/05 16:40:11 INFO - Running backup scripts...
[bbr] 2017/08/05 16:40:11 INFO - Backing up db-backup on db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77...
[bbr] 2017/08/05 16:40:15 INFO - Done.
[bbr] 2017/08/05 16:40:15 INFO - Running post-backup scripts...
[bbr] 2017/08/05 16:40:15 INFO - Unlocking atc-lock on web/e59990aa-2bc8-4958-a563-1346184eef1d...
[bbr] 2017/08/05 16:40:15 INFO - Done.
[bbr] 2017/08/05 16:40:15 INFO - Done.
[bbr] 2017/08/05 16:40:15 INFO - Copying backup -- 12M uncompressed -- from db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77...
[bbr] 2017/08/05 16:40:16 INFO - Finished copying backup -- from db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77...
[bbr] 2017/08/05 16:40:16 INFO - Starting validity checks
[bbr] 2017/08/05 16:40:17 INFO - Finished validity checks
[bbr] 2017/08/05 16:40:17 INFO - Backup created of concourse on 2017-08-05 16:40:17.274401552 +0900 JST
```

`concourse_20170714T092429Z/ ` directory is created.

## Restore Concourse with BBR

```
$ bbr deployment -t 192.168.50.6 -u admin -d concourse --ca-cert ~/uaa_ca restore --artifact-path ./concourse_20170805T073437Z/
[bbr] 2017/08/05 16:40:53 INFO - Starting restore of concourse...
[bbr] 2017/08/05 16:40:55 INFO - web/e59990aa-2bc8-4958-a563-1346184eef1d/atc-lock/post-backup-unlock
[bbr] 2017/08/05 16:40:55 INFO - web/e59990aa-2bc8-4958-a563-1346184eef1d/atc-lock/pre-backup-lock
[bbr] 2017/08/05 16:40:56 INFO - db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77/db-backup/backup
[bbr] 2017/08/05 16:40:56 INFO - db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77/db-backup/restore
[bbr] 2017/08/05 16:40:58 INFO - Copying backup to db/0...
[bbr] 2017/08/05 16:40:58 INFO - Done.
[bbr] 2017/08/05 16:40:58 INFO - Running restore scripts...
[bbr] 2017/08/05 16:40:58 INFO - Restoring db-backup on db/24bdc37b-cc09-4e79-bfa0-1896b3b00e77...
[bbr] 2017/08/05 16:41:03 INFO - Done.
[bbr] 2017/08/05 16:41:03 INFO - Completed restore of concourse
```
