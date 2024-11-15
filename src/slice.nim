type
  # Срез массива
  Slice*[T:SomeNumber] = object
    # Буффер
    data:ptr UncheckedArray[T]
    # Начальная позиция
    pos:Natural
    # Размер среза
    len:Natural

  # Срез массива байт
  Bytes* = Slice[uint8]

# Создаёт новый срез
proc newSlice*[T](size:Positive):Slice[T] =
  return Slice[T](
    data:cast[ptr UncheckedArray[T]](createShared(T, size)),
    pos:0,
    len:size
  )

# Создаёт срез байт заданного размера
proc newBytes*(size:Positive):Bytes =
  return newSlice[uint8](size)

# Создаёт срез байт из буффера
proc newBytes*(data:pointer, pos:Natural, len:Natural):Bytes =
  return Bytes(
    data:cast[ptr UncheckedArray[uint8]](data),
    pos:pos,
    len:len
  )

# Уничтожает срез
proc `=destroy`*[T](x: Slice[T]) =
  deallocShared(x.data)

# Сравнивает два среза байт
proc `==`*(this:Bytes, other:Bytes):bool =
  if this.len != other.len:
    return false

  return cmpMem(this.data[this.pos].addr, other.data[other.pos].addr, other.len) == 0  

# заполняет срез значениями
proc fill*[T](this:Slice[T], value:T) =
  for i in this.pos..<this.len:
    this.data[this.pos+i] = value

# Возвращает элемент среза
proc `[]`*[T](this:Slice[T], pos:Natural):T =
  return this.data[pos]

# Устанавливает элемент среза
proc `[]=`*[T](this:Slice[T], pos:Natural, value:T) =
  this.data[pos] = value

# Возвращает размер среза
proc len*[T](this:Slice[T]):Natural =
    return this.len

# Возвращает буффер небезопасным способом
proc toUnsafe*[T](this:Slice[T]):pointer =
  return this.data