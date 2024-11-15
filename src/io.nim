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

    # Интерфейс для чтения данных с известной длиной
    IReaderSized* = object
        # Читает данные
        reader:IReader   
        # Определяет позицию и размер потока
        sized:ISizedStream

    # Интерфейс для записи данные
    IWriter* = object
        # Записывает срез байт
        write:proc(data:Bytes):void

    # Интерфейс для записи данные с известной длиной
    IWriterSized* = object
        # Записывает данные
        writer:IWriter
        # Определяет позицию и размер потока
        sized:ISizedStream

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

# Преобразует IReaderSized в IReader
converter toIReader*(this:IReaderSized):IReader =
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
proc newISizedStream*():ISizedStream =
    return ISizedStream(

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

# Читает возвращает срез байт
proc readSlice*(this:IReader, size:Natural):Bytes =
    return this.readSlice(size)

# Возвращает интерфейс IOSized
proc sized*(this:IOSized):ISizedStream =
    return this.sized