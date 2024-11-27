import io
import slice

type
     # Поля данных для Memory
     MemoryData = ref object
          # Буффер куда записываются данные
          buffer:pointer
          # Размер выделенного буффера
          capacity:Natural
          # Длина буффера занятого данными
          len:Natural
          # Позиция данных для чтения/записи
          pos:Natural

     # Ввод вывод в память
     Memory* = object
          # Ввод-вывод          
          io:IOSized   
          # Поля данных
          data:MemoryData

# Преобразует в IO
converter toIO*(this:Memory):IOSized =
     return this.io

# Преобразует в IReader
converter toIReader*(this:Memory):IReader =
     return this.io

# Преобразует в IWriter
converter toIWriter*(this:Memory):IWriter =
     return this.io

# Преобразует в IOSized
converter toIOSized*(this:Memory):IOSized =
     return this.io

# Преобразует в ISizedStream
converter toISizedStream*(this:Memory):ISizedStream =
     return this.io

# Подготавливает буффер для записи
proc prepareSize(memdata:MemoryData, size:Natural):void =     
     let totalSize = memdata.pos + size
     if totalSize < memdata.len:
          return
     memdata.buffer = reallocShared(memdata.buffer, totalSize)
     memdata.len = totalSize
     memdata.capacity = totalSize

# Создаёт интерфейс чтения из памяти
proc newMemoryReader(memdata:MemoryData):io.IReader =
     return io.newIReader(
          readUInt8 = proc():uint8 =
               let res = cast[ptr UncheckedArray[uint8]](memdata.buffer)[memdata.pos]
               memdata.pos += 1
               return res
     )

# Создаёт интерфейс записи в память
proc newMemoryWriter(memdata:MemoryData):io.IWriter =
     return io.newIWriter(
          writeBytes = proc(data:Bytes):void =
               prepareSize(memdata, data.len)
               copyMem(memdata.buffer, data.toUnsafe(), data.len)
               memdata.pos += data.len
          ,
          writeUInt8 = proc(value:uint8):void =
               prepareSize(memdata, 1)
               var buff = cast[ptr UncheckedArray[uint8]](memdata.buffer)
               buff[memdata.pos] = value
               memdata.pos += 1
     )

# Создаёт интерфейс для ISizedStream
proc newSized(memdata:MemoryData):io.ISizedStream =
     return newISizedStream(
          getLength = proc():Natural =
               return memdata.len
          ,
          getPos = proc():Natural =
               return memdata.pos
          ,
          setPos = proc(pos:Natural):void =
               memdata.pos = pos
     )

# Создаёт новый ввод-вывод в память
proc newMemory*(capacity = 0):Memory =
     var data = MemoryData(
          buffer:allocShared(capacity),
          capacity:capacity,
          len:0,
          pos:0
     )
     return Memory(
          io: io.newIOSized(
               reader = newMemoryReader(data),
               writer = newMemoryWriter(data),
               sized = newSized(data)
          ),
          data:data
     )

# Возвращает байт памяти по позиции
proc `[]`*(this:Memory, pos:Natural):uint8 =
     discard

# Устанавливает байт памяти по позиции
proc `[]=`*(this:Memory, pos:Natural, value:uint8) =
     var buff = cast[ptr UncheckedArray[uint8]](this.data.buffer)
     buff[pos] = value

# Возвращает длину данных
proc len*(this:Memory):Natural =
     return this.data.len

# Возвращает позицию данных
proc pos*(this:Memory):Natural =
     return this.data.pos

# Заполняет память значением value
proc fill*(this:Memory, value: uint8) =
     for i in 0..<this.data.capacity:
          this[i] = value

# Возвращает срез для буффера в памяти
proc toSlice*(this:Memory):slice.Bytes =
     return slice.newBytes(this.data.buffer, 0, this.len)