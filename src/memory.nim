import io
import slice

type
     # Ввод вывод в память
     Memory* = object
          # Буффер куда записываются данные
          buffer:pointer
          # Ввод-вывод          
          io:io.IO

# Преобразует в IO
converter toIO*(this:Memory):io.IO =
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

# Создаёт новый ввод-вывод в память
proc newMemory*():Memory =
     var buffer = allocShared(0)
     return Memory(
          buffer: buffer,
          io: io.newIO(
               reader = newMemoryReader(buffer),
               writer = newMemoryWriter(buffer),          
          )
     )
     
# Возвращает срез для буффера в памяти
proc toSlice*[T](this:Memory):slice.Bytes =
     discard