fn panic string message =>
    println($"\033[31m{message}\033[0m")
    exit(1)
;