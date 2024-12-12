import asyncdispatch, asyncnet
import sequtils

import io
import exceptions

# Таймаут для чтения данных по умолчанию
const defaultReadTimeoutMs = 1000

type
    # Данные для ввода/вывода асинхронного сокета
    SocketIOAsyncThis = object
        # Асинхронный сокет
        socket:AsyncSocket
        # Таймаут чтения
        readTimeoutMs:Natural

# Читает строку с таймаутом
proc readArrayWithTimeout(ctx:AsyncSocket, length:int, timeoutMs:int) : Future[seq[uint8]] {.async.} =  
  let resFut = ctx.recv(length)
  let resTimeout = await resFut.withTimeout(timeoutMs)
  if not resTimeout:
      resFut.clearCallbacks()
      raise timeoutException

  let str = resFut.read
  if str.len < 1:
    raise disconnectedException

  return str.mapIt(uint8(ord(it)))

# Возвращает интерфейс настроек таймаута
proc getTimeoutStream(this:var SocketIOAsyncThis):IStreamWithTimeout =
    return io.newIStreamWithTimeout(
        getTimeoutMs = proc():Natural =
            return this.readTimeoutMs
        ,
        setTimeoutMs = proc(value:Natural):void =
            this.readTimeoutMs = value
    )

# Возвращает интерфейс читателя
proc getReader(this:SocketIOAsyncThis):IReaderAsync =
    return newIReaderAsync(
    )

# Возвращает интерфейс писателя
proc getWriter(this:SocketIOAsyncThis):IWriterAsync =
    discard

# Создаёт IAsyncIO для асинхронного сокета
proc newIOAsync*(socket:AsyncSocket, readTimeoutMs = defaultReadTimeoutMs):IOAsync =
    var self = SocketIOAsyncThis(
        socket:socket,
        readTimeoutMs:readTimeoutMs
    )

    return io.newIOAsync(
        timeout = getTimeoutStream(self),
        reader = getReader(self),
        writer = getWriter(self)
    )