Process-Locker
==============
Base on redis, same resource should only be processed once. Requests about the resource will be pending until process is complete and then the result will be returned.
基于redis，同一个资源仅会被处理一次，如果一个资源正在处理，当前请求都会被挂起，待处理完成后返回结果。

## Usage:
```
var Locker = require('process-locker')
var locker = Locker()
var key = 'resource-key'
locker.request(key)(function (err, resp) {
  var result
	if (resp.status === Locker.status.LOCKED) {
    // do the process
    // result = ...
    // call publish when job done
    locker.publish(key, result)()
  } else if (resp.status === Locker.status.DONE) {
  	// job with resp.result
    result = resp.result
  }
  ...
})
```

## API:
### Locker(options)
return a locker instance
options:
- **redis** *thunk-redis-client* or *string* use [thunk-redis](https://github.com/thunks/thunk-redis) client to lock and publish events. Default use: `localhost:6379`
- **subRedis** *thunk-redis-client* or *string* use [thunk-redis](https://github.com/thunks/thunk-redis) client to subscribe events. Default use: `localhost:6379`
- **redisPrefix** *String* Default: `locker`
- **channel** *String* channel name for redis subscribe Default: `channel`
- **resultTimeout** *Number* milliseconds to cache the process result Default: `30 * 60 * 1000`
- **lockTimeout** *Number* milliseconds to lock the process result Default: `60 * 60 * 1000`
- **processTimeout** *Number* milliseconds to wait the process result Default: `10 * 60 * 1000`

### Locker.LOCKED
locker locked the key name and you have the only permission to process the resource. So you are the real processor.
### Locker.DONE
locker received the real processor signal and notice all the request.

### locker.request (key)
Request status for process named `key`. If status is `Locker.status.LOCKED`, means you become the real processor. Return a thunk function used with [thunks](https://github.com/thunks/thunks) like `callback(err, resp)`
- **key** *String* the name of the process.
- **resp** *Object*
	- **status** see [Locker.status](#Locker.status) for detail
	- **result** the result processed by the real processor

### locker.publish *(key, object)
return a generator function or used by `callback(err)`
- **key** *String* the name of the process.
- **object** *Json* the result used to notcie all process/request

## TODO:
[X] add timeout error for request waiting the real processer