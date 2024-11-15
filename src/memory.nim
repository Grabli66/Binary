import io
import slice

type
     # Ввод вывод в память
     Memory* = object
          # Ввод-вывод          
          io:io.IOSized
          # Буффер куда записываются данные
          buffer:pointer          

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
proc newMemoryReader(buffer:pointer):io.IReader =
     discard

# Создаёт интерфейс записи в память
proc newMemoryWriter(buffer:pointer):io.IWriter =
     discard

# Создаёт интерфейс для ISizedStream
proc newSized():io.ISizedStream =
     discard

# Создаёт новый ввод-вывод в память
proc newMemory*(capacity = 0):Memory =
     var buffer = allocShared(capacity)
     return Memory(          
          io: io.newIOSized(
               reader = newMemoryReader(buffer),
               writer = newMemoryWriter(buffer),
               sized = newSized()
          ),
          buffer: buffer,
     )

# Возвращает длину данных
proc len*(this:Memory):Natural =
     return this.io.sized.getLength()

# Возвращает срез для буффера в памяти
proc toSlice*[T](this:Memory):slice.Bytes =
     discard