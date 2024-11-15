import slice

type
    # Интерфейс потока данных с известным количеством данных
    ISizedStream* = object
        # Возвращает количество читаемых данных
        getLength:proc():Natural
        # Перематывает в самое начал
        rewind:proc():void
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
        rewind:proc():void,
        getPos:proc():Natural,
        setPos:proc(pos:Natural):void
            ):ISizedStream =
    return ISizedStream(
        getLength:getLength,
        rewind:rewind,
        getPos:getPos,
        setPos:setPos
    )

# Создаёт новый IReader
proc newIReader*():IReader =
    return IReader()

# Создаёт новый IWriter
proc newIWriter*(
        writeBytes:proc(data:Bytes):void):IWriter =
    return IWriter(
        writeBytes:writeBytes
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
proc rewind*(this:ISizedStream):void =
    this.rewind()

# Перенаправляет в ISizedStream
proc pos*(this:ISizedStream):Natural =
    return this.getPos()

# Перенаправляет в ISizedStream
proc `pos=`*(this:ISizedStream, value:Natural):void =
    this.setPos(value)

# Перенаправляет в IWriter
proc writeBytes*(this:IWriter, data:Bytes):void =
    this.writeBytes(data)

# Читает возвращает срез байт
proc readSlice*(this:IReader, size:Natural):Bytes =
    return this.readSlice(size)