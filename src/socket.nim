import asyncnet

import io

# Создаёт IAsyncIO для асинхронного сокета
proc newIOAsync*(socket:AsyncSocket):IOAsync =
    return io.newIOAsync(
    )