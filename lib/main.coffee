request = require 'request'
ftp = require 'jsftp'
ping = require 'ping'
portscanner = require 'portscanner'
async = require 'async'

hackery =
  # Networking stuff
  ping: ping.sys.probe

  scan: (host, port, cb) ->
    portscanner.checkPortStatus port, host, (err, res) ->
      cb !err and res isnt 'closed'

  scanAll: (host, ports, cb) ->
    it = (port, cb) -> 
      hackery.scan host, port, cb

    async.filter ports, it, cb

  scanRange: (host, start, finish, cb) ->
    hackery.scanAll host, [start..finish], cb

  # FTP Stuff
  ftp: ftp
  checkFtp: (opt={}, cb) ->
    opt.user ?= "Anonymous"
    opt.pass ?= ""
    conn = new ftp
      host: opt.host
      port: opt.port
    conn.auth opt.user, opt.pass, (err, res) -> 
      conn.features ?= []
      conn.authorized ?= !err
      cb conn.authorized, conn.features, conn

  # HTTP Stuff
  http: request
  checkHttp: (opt={}, cb) ->
    opt.user ?= "admin"
    opt.pass ?= "admin"
    opt.port ?= 80
    opt.host = "http://#{opt.user}:#{opt.pass}@#{opt.host}:#{opt.port}"
    request opt.host, (err, res, body) ->
      return cb err if err?
      return cb null, body

module.exports = hackery