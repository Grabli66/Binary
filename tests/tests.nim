import unittest

import binary

test "create slice":
  const size = 10
  let bytes = newSlice[uint8](size)
  check bytes.size == size

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
  const size = 10
  var mem = newMemory(size)
  check mem.len == size
