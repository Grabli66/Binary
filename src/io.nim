import slice

type
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
        write:proc(data:Bytes):void

    # Ввод вывод
    IO* = object
        # Читает данные
        reader:IReader
        # Записывает данные
        writer:IWriter

# Преобразует в IReader
converter toIReader*(this:IO):IReader =
     return this.reader

# Преобразует в IWriter
converter toIWriter*(this:IO):IWriter =
     return this.writer

# Создаёт новое IO
proc newIO*(reader:IReader, writer:IWriter):IO =
    return IO(
        reader:reader,
        writer:writer
    )

# Читает возвращает срез байт
proc readSlice*(this:IReader, size:Natural):Bytes =
    return this.readSlice(size)