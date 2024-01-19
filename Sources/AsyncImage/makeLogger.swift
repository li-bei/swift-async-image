import os

func makeLogger(category: String = #file) -> Logger {
    return Logger(subsystem: "me.libei.AsyncImage", category: category)
}
