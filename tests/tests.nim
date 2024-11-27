import unittest

import binary
#import print

test "create slice":
  const size = 10
  let bytes = newSlice[uint8](size)
  check bytes.len == size

test "fill slice":
  const size = 10
  let bytes = newSlice[uint8](size)
  const fillvalue = 3
  bytes.fill(fillvalue)
  var checked = true
  for i in 0..<size:
    if bytes[i] != fillvalue:
      checked = false
      break

  check checked

test "memory create":  
  var mem = newMemory(10)
  check mem.len == 0

test "memory set/get pos":
  var mem = newMemory(10)
  mem.pos = 7
  check mem.pos == 7

test "memory write bytes":
  var mem = newMemory(10)
  var bytes = newBytes(5)
  bytes.fill(33)

  mem.writeBytes(bytes)
  var slice = mem.toSlice()
  check slice == bytes

test "memory write uint8":
  var mem = newMemory(10)
  mem.write(uint8, 10)
  var sl = mem.toSlice()
  check sl[0] == 10

test "memory read uint8":
  var mem = newMemory(10)
  const fillBt = 0x03u8
  mem.fill(fillBt)
  mem.rewind()
  let bt = mem.read(uint8)
  check bt == fillBt