type
  # Срез массива
  Slice*[T:SomeNumber] = object
    # Буффер
    data:ptr UncheckedArray[T]
    # Начальная позиция
    pos:Natural
    # Размер среза
    size:Natural

  # Срез массива байт
  Bytes* = Slice[uint8]

# Создаёт новый срез
proc newSlice*[T](size:Positive):Slice[T] =
  return Slice[T](
    data:cast[ptr UncheckedArray[T]](createShared(T, size)),
    pos:0,
    size:size
  )

# Создаёт срез байт
proc newBytes*(size:Positive):Bytes =
  return newSlice[uint8](size)

# Уничтожает срез
proc `=destroy`*[T](x: Slice[T]) =
  deallocShared(x.data)

# заполняет срез значениями
proc fill*[T](this:Slice[T], value:T) =
  for i in this.pos..<this.size:
    this.data[this.pos+i] = value

# Возвращает элемент среза
proc `[]`*[T](this:Slice[T], pos:Natural):T =
  return this.data[pos]

# Устанавливает элемент среза
proc `[]=`*[T](this:Slice[T], pos:Natural, value:T) =
  this.data[pos] = value

# Возвращает размер среза
proc size*[T](this:Slice[T]):Natural =
    return this.size