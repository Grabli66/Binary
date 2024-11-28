import slice

type
    # Байт
    SomeByte = uint8|int8

    # Число, но не байт
    SomeNotByteNumber = uint16|int16|uint32|int32|uint64|int64|float32|float64

    # Интерфейс потока данных с известным количеством данных
    ISizedStream* = object
        # Возвращает количество читаемых данных
        getLength:proc():Natural
        # Возвращает позицию для чтения
        getPos:proc():Natural
        # Устанавливает позицию для чтения
        setPos:proc(pos:Natural):void

    # Интерфейс для чтения данных
    IReader* = object
        # Читает возвращает срез байт
        readSlice:proc(size:Natural):Bytes
        # Читает uint8
        readUInt8:proc():uint8
        # Читает uin16
        readUInt16:proc(endian:Endianness):uint16
        # Читает uin32
        readUInt32:proc(endian:Endianness):uint32
        # Читает uin64
        readUInt64:proc(endian:Endianness):uint64

    # Интерфейс для записи данные
    IWriter* = object        
        # Записывает срез байт
        writeBytes:proc(data:Bytes):void        
        # Записывает UInt8
        writeUInt8:proc(value:uint8):void

    # Ввод-вывод
    IO* = object
        # Читает данные
        reader:IReader
        # Записывает данные
        writer:IWriter

    # Ввод-вывод с известной длинной
    IOSized* = object
        # Читает данные
        reader:IReader
        # Записывает данные
        writer:IWriter
        # Определяет позицию и размер потока
        sized:ISizedStream

# Преобразует IO в IReader
converter toIReader*(this:IO):IReader =
     return this.reader

# Преобразует IOSized в IReader
converter toIReader*(this:IOSized):IReader =
     return this.reader

# Преобразует IO в IWriter
converter toIWriter*(this:IO):IWriter =
     return this.writer

# Преобразует IOSized в IWriter
converter toIWriter*(this:IOSized):IWriter =
     return this.writer

# Преобразует IOSized в IO
converter toIO*(this:IOSized):IO =
    return IO(
        reader:this.reader,
        writer:this.writer
    )

# Преобразует IOSized в ISizedStream
converter toISizedStream*(this:IOSized):ISizedStream =
    return this.sized

# Создаёт новое ISizedStream
proc newISizedStream*(
        getLength:proc():Natural,
        getPos:proc():Natural,
        setPos:proc(pos:Natural):void
            ):ISizedStream =
    return ISizedStream(
        getLength:getLength,        
        getPos:getPos,
        setPos:setPos
    )

# Создаёт новый IReader
proc newIReader*(
        readUInt8:proc():uint8,
        readUInt16:proc(endian:Endianness):uint16,
        readUInt32:proc(endian:Endianness):uint32,
        readUInt64:proc(endian:Endianness):uint64):IReader =
    return IReader(
        readUInt8:readUInt8,
        readUInt16:readUInt16,
        readUInt32:readUInt32,
        readUInt64:readUInt64
    )

# Создаёт новый IWriter
proc newIWriter*(
        writeBytes:proc(data:Bytes):void,
        writeUInt8:proc(value:uint8):void):IWriter =
    return IWriter(
        writeBytes:writeBytes,
        writeUInt8:writeUInt8
    )

# Создаёт новое IO
proc newIO*(reader:IReader, writer:IWriter):IO =
    return IO(
        reader:reader,
        writer:writer
    )

# Создаёт новое IOSized
proc newIOSized*(reader:IReader,writer:IWriter,sized:ISizedStream):IOSized =
    return IOSized(
        reader:reader,
        writer:writer,
        sized:sized
    )

# Перенаправляет в ISizedStream
proc getLength*(this:ISizedStream):Natural =
    return this.getLength()

# Перенаправляет в ISizedStream
proc pos*(this:ISizedStream):Natural =
    return this.getPos()

# Перенаправляет в ISizedStream
proc `pos=`*(this:ISizedStream, value:Natural):void =
    this.setPos(value)

# Перематывает в начало
proc rewind*(this:ISizedStream):void =
    this.pos = 0

# Перенаправляет в IWriter
proc writeBytes*(this:IWriter, data:Bytes):void =
    this.writeBytes(data)

# Записывает SomeByte значение через IWriter
proc write*(this:IWriter, T:typedesc[SomeByte], value:T):void =
    when T is uint8:
        this.writeUInt8(value)
    when T is int8:
        this.writeUInt8(value.uint8)

# Читает возвращает срез байт
proc readSlice*(this:IReader, size:Natural):Bytes =
    return this.readSlice(size)

# Читает значение SomeByte через IReader
proc read*(this:IReader, T:typedesc[SomeByte]):T =
    when T is uint8:
        return this.readUInt8()
    when T is int8:
        return this.readUInt8().int8

# Читает значение SomeNotByteNumber через IReader
proc read*(this:IReader, T:typedesc[SomeNotByteNumber], endian:Endianness):T =
    when T is uint16:
        return this.readUint16(endian)
    when T is int16:
        return this.readUint16(endian).int16
    when T is uint32:
        return this.readUint32(endian)
    when T is int32:
        return this.readUint32(endian).int32
    when T is uint64:
        return this.readUint64(endian)
    when T is int64:
        return this.readUint64(endian).int64