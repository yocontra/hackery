hackery = require '../index'
should = require 'should'
mocha = require 'mocha'

describe 'hackery', ->
  describe 'ftp', ->
    it 'should login to a public ftp properly', (done) ->
      @timeout = 3000
      hackery.checkFtp {host: '216.38.80.156'}, (valid, perms, conn) ->
        should.exist valid
        valid.should.equal true
        should.exist perms
        perms.should.be.instanceof Array
        should.exist conn
        conn.raw.quit (err, res) ->
          should.exist res
          should.exist res.code
          res.code.should.equal 221
          done()

    it 'should fail to login with an invalid user', (done) ->
      @timeout = 3000
      hackery.checkFtp {user: 'bar', pass: 'foo', host: '216.38.80.156'}, (valid, perms, conn) ->
        should.exist valid
        valid.should.equal false
        done()

    it 'should fail to login to an invalid server', (done) ->
      @timeout = 3000
      hackery.checkFtp {host: 'google.com'}, (valid, perms, conn) ->
        should.exist valid
        valid.should.equal false
        done()

  describe 'ping', ->
    it 'should report github as online', (done) ->
      @timeout = 1000
      hackery.ping 'github.com', (online) ->
        should.exist online
        online.should.equal true
        done()

    it 'should report an fizzbaromgw0t.com site as offline', (done) ->
      @timeout = 1000
      hackery.ping 'fizzbaromgw0t.com', (online) ->
        should.exist online
        online.should.equal false
        done()

  describe 'scan', ->
    it 'should report github.com:10 as closed', (done) ->
      @timeout = 1000
      hackery.scan 'github.com', 10, (open) ->
        should.exist open
        open.should.equal false
        done()

    it 'should report github.com:80 as open', (done) ->
      @timeout = 1000
      hackery.scan 'github.com', 80, (open) ->
        should.exist open
        open.should.equal true
        done()

    it 'should report github.com:80 as open when scanning 75-85', (done) ->
      @timeout = 10000
      hackery.scanRange 'github.com', 75, 85, (open) ->
        should.exist open
        open.indexOf(80).should.not.equal -1
        done()

    it 'should report github.com:80 and 22 as open when scanning 22, 80 and 85', (done) ->
      @timeout = 3000
      hackery.scanAll 'github.com', [22, 80], (open) ->
        should.exist open
        open.indexOf(85).should.equal -1
        open.indexOf(22).should.not.equal -1
        open.indexOf(80).should.not.equal -1
        done()