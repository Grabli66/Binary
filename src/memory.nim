import io
import slice

type
     # Поля данных для Memory
     MemoryData = ref object
          # Буффер куда записываются данные
          buffer:pointer
          # Длина буффера
          len:Natural
          # Позиция данных для чтения/записи
          pos:Natural

     # Ввод вывод в память
     Memory* = object
          # Ввод-вывод          
          io:io.IOSized   
          # Поля данных
          data:MemoryData

# Преобразует в IO
converter toIO*(this:Memory):io.IOSized =
     return this.io

# Преобразует в IReader
converter toIReader*(this:Memory):IReader =
     return this.io

# Преобразует в IWriter
converter toIWriter*(this:Memory):IWriter =
     return this.io

# Создаёт интерфейс чтения из памяти
proc newMemoryReader(memdata:MemoryData):io.IReader =
     return io.newIReader(

     )

# Создаёт интерфейс записи в память
proc newMemoryWriter(memdata:MemoryData):io.IWriter =
     return io.newIWriter(
          write = proc(data:Bytes):void =
               copyMem(memdata.buffer, data.toUnsafe(), data.len)
     )

# Создаёт интерфейс для ISizedStream
proc newSized(memdata:MemoryData):io.ISizedStream =
     return newISizedStream(
          getLength = proc():Natural =
               return memdata.len
     )

# Создаёт новый ввод-вывод в память
proc newMemory*(capacity = 0):Memory =
     var data = MemoryData(
          buffer:allocShared(capacity),
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

# Возвращает длину данных
proc len*(this:Memory):Natural =
     return this.data.len

# Возвращает позицию данных
proc pos*(this:Memory):Natural =
     return this.data.pos

# Возвращает срез для буффера в памяти
proc toSlice*[T](this:Memory):slice.Bytes =
     discard