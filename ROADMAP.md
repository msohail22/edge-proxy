# Edge Proxy — 1000 Program Roadmap

## How to Read

Each program builds on the previous. Folder trees are shown at key milestones showing the project's growth.

```
P### | Title
  File: path (create | modify)  Dep: P###
  What it does in one line.
  Verify: command
```

---

## Phase 0: Project Scaffold & Infrastructure
**P001–P080 | 80 programs | A compilable C++20 project with build, types, errors, logging, config, test harness.**

---

### 0.1 Build System & Toolchain

```
P001 | Initialize CMake project with C++20
  File: CMakeLists.txt (create)  Dep: none
  cmake_minimum_required(VERSION 3.20), project(edge_proxy), C++20, -Wall -Wextra -Werror.
  Verify: cmake -B build && cmake --build build

P002 | Add output binary directory and install target
  File: CMakeLists.txt (modify)  Dep: P001
  CMAKE_RUNTIME_OUTPUT_DIRECTORY, install(TARGETS edge_proxy).
  Verify: ls build/bin/edge_proxy

P003 | Create modular CMake library targets
  File: CMakeLists.txt (modify)  Dep: P002
  Static libs: edge_core, edge_net, edge_http, edge_mem, edge_sync, edge_io.
  Verify: cmake --build build

P004 | Add subdirectory CMakeLists for each library
  File: CMakeLists.txt (modify), src/core/CMakeLists.txt, src/net/CMakeLists.txt,
        src/http/CMakeLists.txt, src/mem/CMakeLists.txt, src/sync/CMakeLists.txt,
        src/io/CMakeLists.txt (create)
  Dep: P003
  add_subdirectory for each.
  Verify: cmake --build build

P005 | Configure build types (Debug, Release, RelWithDebInfo)
  File: CMakeLists.txt (modify)  Dep: P004
  Debug: -O0 -g. Release: -O3 -march=native -DNDEBUG. RelWithDebInfo: -O2 -g.
  Verify: cmake -B build -DCMAKE_BUILD_TYPE=Release

P006 | Set up Ccache integration
  File: CMakeLists.txt (modify)  Dep: P005
  find_program(CCACHE ccache), CMAKE_CXX_COMPILER_LAUNCHER.
  Verify: cmake --build build

P007 | Add clang-tidy and clang-format targets
  File: CMakeLists.txt (modify), .clang-tidy (create), .clang-format (create)
  Dep: P006
  Google style, 100 cols, modernize-* checks. format and lint targets.
  Verify: cmake --build build --target format

P008 | Export compile_commands.json
  File: CMakeLists.txt (modify)  Dep: P007
  CMAKE_EXPORT_COMPILE_COMMANDS ON. Symlink to project root.
  Verify: ls build/compile_commands.json

P009 | Configure Link-Time Optimization
  File: CMakeLists.txt (modify)  Dep: P008
  include(CheckIPOSupported), CMAKE_INTERPROCEDURAL_OPTIMIZATION ON for Release.
  Verify: cmake --build build -DCMAKE_BUILD_TYPE=Release

P010 | Generate version header from Git
  File: CMakeLists.txt (modify), include/core/version.hpp.in (create)
  Dep: P009
  configure_file with PROJECT_VERSION and git describe.
  Verify: build/include/core/version.hpp exists
```

### 0.2 Directory Structure & Placeholders

```
P011 | Create all stub headers for every module
  File: include/core/types.hpp, error.hpp, logger.hpp, config.hpp,
        include/net/socket.hpp, epoll.hpp, connection.hpp,
        include/http/parser.hpp, request.hpp, response.hpp,
        include/mem/slab.hpp, arena.hpp, pool.hpp, buffer.hpp,
        include/sync/spsc.hpp, thread_pool.hpp, affinity.hpp,
        include/io/io_uring.hpp, xdp.hpp,
        include/simd/scan.hpp,
        include/telemetry/metrics.hpp, latency.hpp (create)
  Dep: P010
  #pragma once + minimal stub comment.
  Verify: cmake --build build

P012 | Create all stub source files
  File: src/core/error.cpp, logger.cpp, config.cpp,
        src/net/socket.cpp, epoll.cpp, connection.cpp,
        src/http/parser.cpp, request.cpp, response.cpp,
        src/mem/slab.cpp, arena.cpp, pool.cpp, buffer.cpp,
        src/sync/spsc.cpp, thread_pool.cpp, affinity.cpp,
        src/io/io_uring.cpp, src/simd/scan.cpp,
        src/telemetry/metrics.cpp (create)
  Dep: P011
  Stub .cpp with #include and empty function bodies.
  Verify: cmake --build build

P013 | Add third-party dependencies via FetchContent
  File: CMakeLists.txt (modify), cmake/ (create)
  Dep: P012
  Google Benchmark, picohttpparser. Targets for linking.
  Verify: cmake --build build downloads dependencies

P014 | Create test directory scaffold with CTest
  File: tests/CMakeLists.txt, tests/unit/CMakeLists.txt,
        tests/integration/CMakeLists.txt, tests/unit/test_placeholder.cpp (create)
  Dep: P013
  enable_testing, add_test. Placeholder test that always passes.
  Verify: ctest --test-dir build

P015 | Create benchmark directory scaffold
  File: benchmarks/CMakeLists.txt, benchmarks/BM_placeholder.cpp (create)
  Dep: P014
  find_package(benchmark REQUIRED). Stub benchmark.
  Verify: cmake --build build --target benchmark

P016 | Create scripts directory
  File: scripts/benchmark.sh, profile.sh, run_load_test.sh, setup_dev.sh (create)
  Dep: P015
  Stub shell scripts with usage() and args. chmod +x.
  Verify: scripts/benchmark.sh --help

P017 | Create GitHub Actions CI workflow
  File: .github/workflows/ci.yml (create)  Dep: P016
  Build on push/PR to master. Matrix: gcc-13, clang-16. Debug + Release.
  Verify: workflow YAML is valid

P018 | Create GitHub Actions nightly benchmark workflow
  File: .github/workflows/benchmark.yml (create)  Dep: P017
  Nightly Release build, run Google Benchmark, publish artifacts.
  Verify: workflow YAML is valid

P019 | Create .clangd configuration
  File: .clangd (create)  Dep: P018
  -std=c++20 and compile_commands.json path.
  Verify: clangd --check=src/main.cpp

P020 | Initialize AGENTS.md with development conventions
  File: AGENTS.md (create)  Dep: P019
  Build commands, test commands, naming conventions, error handling style.
  Verify: file renders in markdown
```

### Folder Tree After P020

```
edge-proxy/
├── CMakeLists.txt              # top-level build
├── .clang-format               # C++ formatting rules
├── .clang-tidy                 # static analysis config
├── .clangd                     # LSP config
├── AGENTS.md                   # dev conventions
├── Dockerfile / .dockerignore / .gitignore / README.md
├── cmake/                      # FetchContent scripts
├── scripts/                    # benchmark.sh, profile.sh, run_load_test.sh, setup_dev.sh
├── include/
│   ├── core/   (types.hpp, platform.hpp, error.hpp, logger.hpp, config.hpp, version.hpp.in)
│   ├── net/    (socket.hpp, epoll.hpp, connection.hpp, address.hpp)
│   ├── http/   (parser.hpp, request.hpp, response.hpp, header.hpp, method.hpp)
│   ├── mem/    (slab.hpp, arena.hpp, pool.hpp, buffer.hpp)
│   ├── sync/   (spsc.hpp, thread_pool.hpp, affinity.hpp)
│   ├── io/     (io_uring.hpp, xdp.hpp)
│   ├── simd/   (scan.hpp)
│   └── telemetry/ (metrics.hpp, latency.hpp)
├── src/
│   ├── main.cpp
│   ├── core/CMakeLists.txt + (error.cpp, logger.cpp, config.cpp)
│   ├── net/CMakeLists.txt  + (socket.cpp, epoll.cpp, connection.cpp)
│   ├── http/CMakeLists.txt + (parser.cpp, request.cpp, response.cpp)
│   ├── mem/CMakeLists.txt  + (slab.cpp, arena.cpp, pool.cpp, buffer.cpp)
│   ├── sync/CMakeLists.txt + (spsc.cpp, thread_pool.cpp, affinity.cpp)
│   ├── io/CMakeLists.txt   + (io_uring.cpp)
│   ├── simd/CMakeLists.txt + (scan.cpp)
│   └── telemetry/CMakeLists.txt + (metrics.cpp)
├── tests/
│   ├── CMakeLists.txt
│   ├── unit/CMakeLists.txt + test_placeholder.cpp
│   └── integration/CMakeLists.txt
├── benchmarks/
│   ├── CMakeLists.txt
│   └── BM_placeholder.cpp
└── .github/workflows/ (ci.yml, benchmark.yml)
```

### 0.3 Type System & Platform Abstraction

```
P021 | Define explicit-width integer types
  File: include/core/types.hpp (modify)  Dep: P011
  u8, u16, u32, u64, i8, i16, i32, i64, usize, ssize.
  Verify: static_assert sizeof each

P022 | Define network-portable big-endian integer types
  File: include/core/types.hpp (modify)  Dep: P021
  net_u16, net_u32 structs with explicit byte accessors.
  Verify: static_assert size and alignment

P023 | Add endianness detection and byte-swap utilities
  File: include/core/types.hpp (modify)  Dep: P022
  constexpr bool kIsLittleEndian, betoh16/32, htobe16/32 via __builtin_bswap.
  Verify: static_assert round-trip conversion

P024 | Add compile-time platform detection macros
  File: include/core/platform.hpp (create)  Dep: P023
  EDGE_LINUX, EDGE_X86_64, EDGE_ARM64, EDGE_CLANG, EDGE_GCC.
  Verify: preprocessor output confirms detection

P025 | Add compiler attribute macros
  File: include/core/platform.hpp (modify)  Dep: P024
  EDGE_ALWAYS_INLINE, EDGE_NEVER_INLINE, EDGE_COLD, EDGE_HOT, EDGE_PACKED,
  EDGE_ALIGNED(n), EDGE_LIKELY(x), EDGE_UNLIKELY(x), EDGE_NODISCARD, EDGE_UNREACHABLE.
  Verify: each macro compiles

P026 | Add cache line alignment utilities
  File: include/core/platform.hpp (modify)  Dep: P025
  constexpr size_t kCacheLineSize = 64. alignas(kCacheLineSize). EDGE_CACHE_ALIGNED.
  Verify: alignof(AlignAsCacheLine) == 64

P027 | Define strong typedef helper macro
  File: include/core/types.hpp (modify)  Dep: P024
  EDGE_STRONG_TYPEDEF(Type, Name). Wrapper struct with .value() accessor.
  Verify: cannot mix two strong typedefs

P028 | Define FileDescriptor strong typedef
  File: include/core/types.hpp (modify)  Dep: P027
  EDGE_STRONG_TYPEDEF(int, FileDescriptor). kInvalidFd = -1. IsValid().
  Verify: static_assert(kInvalidFd == -1)

P029 | Define Result<T> monadic error-or-value type
  File: include/core/types.hpp (modify)  Dep: P028
  template<typename T> Result with Success(T), Error(ErrorCode). HasValue/Value/Error.
  Verify: unit test exercises both paths

P030 | Define Status type (void Result)
  File: include/core/types.hpp (modify)  Dep: P029
  using Status = Result<std::monostate>. kSuccess = Status() constant.
  Verify: unit test verifies Status propagation

P031 | Define Slice<T> view type (pointer + size)
  File: include/core/types.hpp (modify)  Dep: P030
  template<typename T> Slice { T* data; size_t size; }. Iterator, operator[], Subslice.
  Verify: unit test exercises all methods

P032 | Define ByteSlice and ConstByteSlice
  File: include/core/types.hpp (modify)  Dep: P031
  using ByteSlice = Slice<std::byte>; using ConstByteSlice = Slice<const std::byte>.
  Verify: static_assert size checks

P033 | Add CPU feature detection (AVX2, AVX-512, SSE4.2)
  File: include/core/platform.hpp (modify)  Dep: P026
  struct CpuFeatures { bool avx2; bool avx512; bool sse4_2; }. DetectCpuFeatures().
  Verify: prints detected features

P034 | Define OS socket constants abstraction
  File: include/core/platform.hpp (modify)  Dep: P033
  kInvalidSocket, kMaxListenBacklog (SOMAXCONN), kMaxEvents, kBufferSize(65536).
  Verify: values match system limits

P035 | Add move-only and non-copyable helpers
  File: include/core/types.hpp (modify)  Dep: P034
  EDGE_DEFAULT_MOVE_AND_ASSIGN macro. EDGE_DISALLOW_COPY(type) macro.
  Verify: test compiles with move-only semantics
```

### 0.4 Error Handling Infrastructure

```
P036 | Define ErrorCode enum mapping POSIX errors
  File: include/core/error.hpp (modify)  Dep: P030
  kOk, kUnknown, kNotFound, kPermissionDenied, kConnectionRefused, kTimeout, etc.
  Verify: unit test round-trips through ToString()

P037 | Implement ErrorCode from errno mapping
  File: include/core/error.hpp (modify), src/core/error.cpp (modify)  Dep: P036
  ErrorCode ErrorCodeFromErrno(int). Maps EAGAIN/EWOULDBLOCK, ECONNREFUSED, etc.
  Verify: test with known errno values

P038 | Implement ErrorCode to string conversion
  File: src/core/error.cpp (modify)  Dep: P037
  const char* ErrorCodeToString(ErrorCode). Switch with no default.
  Verify: all enum values produce non-null strings

P039 | Add source location capture (std::source_location)
  File: include/core/error.hpp (modify)  Dep: P038
  struct SourceLocation wrapping source_location. File(), Line(), Function().
  Verify: static_assert source_location::current().line() > 0

P040 | Add ErrorInfo struct (code + location)
  File: include/core/error.hpp (modify)  Dep: P039
  struct ErrorInfo { ErrorCode code; SourceLocation location; }. Format() -> string.
  Verify: format matches expected

P041 | Update Result<T> to carry ErrorInfo
  File: include/core/types.hpp (modify)  Dep: P040
  Result<T>::Error() returns const ErrorInfo&. Backward compatible.
  Verify: existing tests pass

P042 | Add EDGE_TRY macro for early return
  File: include/core/error.hpp (modify)  Dep: P041
  #define EDGE_TRY(expr) do { auto _r = (expr); if (!_r.HasValue()) return _r.Error(); } while(0)
  Verify: function with EDGE_TRY compiles

P043 | Add EDGE_ASSERT and EDGE_VERIFY macros
  File: include/core/error.hpp (modify)  Dep: P042
  EDGE_ASSERT(cond) = assert in debug. EDGE_VERIFY(cond) = terminate both.
  Verify: test verifies termination on failure

P044 | Add EDGE_PANIC for unrecoverable errors
  File: include/core/error.hpp (modify)  Dep: P043
  [[noreturn]] void Panic(msg, SourceLocation). Prints message + backtrace, abort().
  Verify: call triggers abort

P045 | Add EDGE_CHECK macro with streaming
  File: include/core/error.hpp (modify)  Dep: P044
  EDGE_CHECK(cond) << "msg". If false, format message and panic.
  Verify: test with false condition

P046 | Add Syscall wrapper with EINTR retry
  File: include/core/error.hpp (modify)  Dep: P045
  template<typename F> auto Syscall(F&& fn) -> Result<decltype(fn())>.
  Calls fn, checks return, converts errno, retries on EINTR.
  Verify: test with intentionally failing syscall

P047 | Add ErrnoGuard (save/restore errno)
  File: include/core/error.hpp (modify)  Dep: P046
  class ErrnoGuard { int saved_; ~ErrnoGuard() { errno = saved_; } }.
  Verify: errno unchanged after guard scope

P048 | Create unit test file for error module
  File: tests/unit/test_error.cpp (create)  Dep: P047
  ErrorCode mapping, ErrorInfo formatting, Result propagation, EDGE_TRY, EDGE_ASSERT.
  Verify: ctest -R test_error passes

P049 | Add error module test to CMake
  File: tests/unit/CMakeLists.txt (modify)  Dep: P048
  add_executable(test_error test_error.cpp) linking edge_core. add_test.
  Verify: ctest --test-dir build -R test_error passes

P050 | Document error handling conventions in AGENTS.md
  File: AGENTS.md (modify)  Dep: P049
  Prefer Result<T> over exceptions. EDGE_TRY/EDGE_ASSERT/EDGE_CHECK.
  Verify: document renders correctly
```

### 0.5 Logging Infrastructure

```
P051 | Define LogLevel enum
  File: include/core/logger.hpp (modify)  Dep: P030
  Trace, Debug, Info, Warn, Error, Fatal. kDefaultLogLevel = Info. ToString/FromString.
  Verify: test round-trip through all levels

P052 | Create LogMessage struct
  File: include/core/logger.hpp (modify)  Dep: P051
  struct LogMessage { LogLevel; string_view file; int line; string_view msg; Timestamp; }.
  Verify: sizeof < 128 bytes

P053 | Implement LogWriter abstract base class
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P052
  class LogWriter { virtual void Write(const LogMessage&) = 0; virtual ~LogWriter() = default; }.
  Verify: test subclass compiles

P054 | Implement StderrLogWriter (colored output)
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P053
  Colors: green Info, yellow Warn, red Error, bold red Fatal. Timestamp prefix.
  Verify: visual inspection

P055 | Implement FileLogWriter
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P054
  Opens file on construction. Appends log lines. Buffered with periodic flush.
  Verify: log file contains expected lines

P056 | Create Logger class with level filtering
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P055
  SetLevel, AddWriter, Log(level, fmt...). snprintf formatting. Filters below SetLevel.
  Verify: messages below level suppressed

P057 | Add log macro wrappers (LOG_TRACE..LOG_FATAL)
  File: include/core/logger.hpp (modify)  Dep: P056
  Macros capture SourceLocation. Global Logger* gLogger (nullptr-safe, no-op if null).
  Verify: macros compile with correct locations

P058 | Implement global logger initialization
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P057
  Logger* GetOrCreateLogger(). Singleton with StderrLogWriter at Info level. call_once.
  Verify: returns same pointer twice

P059 | Add rate-limited logging
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P058
  LOG_WARN_EVERY_N, LOG_WARN_FIRST_N. Uses static hashtable rate limiter.
  Verify: test with 100 calls, only 10 logged

P060 | Add structured logging with key-value pairs
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P059
  LOG_INFO("msg", "key"_kv=val). KeyValue helper with operator""_kv.
  Verify: output contains structured fields

P061 | Add log level from EDGE_LOG_LEVEL environment variable
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P060
  On init, read EDGE_LOG_LEVEL env var. Maps trace/debug/info/warn/error/fatal.
  Verify: EDGE_LOG_LEVEL=debug changes output

P062 | Implement AsyncLogWriter (background thread)
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P061
  Internal SPSC queue. Background thread drains and forwards.
  Verify: benchmark shows non-blocking

P063 | Add log rotation for FileLogWriter
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P062
  Rotate on size threshold (100MB). Keep N rotated files. Rename, open new.
  Verify: force rotation creates new file

P064 | Create unit test file for logger module
  File: tests/unit/test_logger.cpp (create)  Dep: P063
  Level conversion, filtering, macro compilation, StderrLogWriter capture.
  Verify: ctest -R test_logger passes

P065 | Add logger benchmark
  File: benchmarks/BM_Logger.cpp (create)  Dep: P064
  Hot-path vs disabled vs async logging. ns/call.
  Verify: consistent numbers
```

### 0.6 Configuration Management

```
P066 | Define ConfigKey enum
  File: include/core/config.hpp (modify)  Dep: P030
  ListenHost, ListenPort, UpstreamHost, UpstreamPort, WorkerThreads, LogLevel, etc.
  Verify: all keys compile

P067 | Define ConfigValue variant
  File: include/core/config.hpp (modify)  Dep: P066
  using ConfigValue = variant<string, int64_t, bool, double>. Typed accessors.
  Verify: variant holds expected types

P068 | Create Config class
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P067
  Set(ConfigKey, ConfigValue), Get(key, default). Internal flat_hash_map.
  Verify: round-trip set/get

P069 | Add typed accessors with defaults
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P068
  GetString(key, default), GetInt(key, default), GetBool(key, default).
  Verify: test with each typed accessor

P070 | Add CLI argument parser (long options)
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P069
  --listen-host, --listen-port, --upstream, --workers, --log-level, --help.
  Verify: --help prints usage

P071 | Add short option aliases
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P070
  -h (help), -p (port), -u (upstream), -w (workers). Uses getopt_long.
  Verify: -p 9090 == --listen-port 9090

P072 | Add config file parser (KEY=VALUE or TOML-style)
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P071
  KEY=VALUE or [section] key = value. Comments with #. CLI overrides file.
  Verify: config file with all keys parses

P073 | Add environment variable overrides
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P072
  Config MergeEnvOverrides(). Reads EDGE_LISTEN_HOST, EDGE_LISTEN_PORT, etc.
  Verify: EDGE_LISTEN_PORT=9090 overrides file

P074 | Implement config validation
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P073
  Port [1,65535], workers [1,128], timeouts >= 0, upstream host set.
  Verify: invalid configs produce meaningful errors

P075 | Add config defaults initialization
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P074
  DefaultConfig(): ListenHost=0.0.0.0, ListenPort=8080, Workers=0, LogLevel=Info.
  Verify: defaults are reasonable

P076 | Implement ConfigBuilder fluent API
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P075
  SetListenPort(), SetUpstream(), Build().
  Verify: builder produces expected Config

P077 | Add config dump for startup logging
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P076
  string ConfigToString(). Masks TLS key paths.
  Verify: log output shows config

P078 | Wire main.cpp with config initialization
  File: src/main.cpp (modify)  Dep: P077
  DefaultConfig -> ParseCliArgs -> ParseConfigFile -> MergeEnv -> Validate -> InitLogger.
  Verify: ./edge_proxy --help, --port 9090 works

P079 | Create unit test file for config module
  File: tests/unit/test_config.cpp (create)  Dep: P078
  Defaults, CLI parsing, file parsing, env overrides, validation, dump.
  Verify: ctest -R test_config passes

P080 | Add config documentation comment block
  File: include/core/config.hpp (modify)  Dep: P079
  Doxygen comments on each ConfigKey: purpose, values, default, example.
  Verify: documentation renders in IDE
```

---

## Phase 1: Asynchronous Foundation — Event-Driven I/O
**P081–P330 | 250 programs | Non-blocking network core handling 10k+ concurrent connections on a single thread.**

---

### 1.1 Socket Abstraction Layer

```
P081 | SocketAddressV4 wrapper
  File: include/net/address.hpp (create), src/net/address.cpp (create)  Dep: P028, P035
  FromHostPort(host, port) -> sockaddr_in. ToString().
  Verify: "127.0.0.1:8080" produces correct sockaddr_in

P082 | SocketAddressV6 wrapper
  File: include/net/address.hpp (modify), src/net/address.cpp (modify)  Dep: P081
  struct SocketAddressV6 { sockaddr_in6 addr; }.
  Verify: "[::1]:8080" parses

P083 | Address union (IPv4 | IPv6)
  File: include/net/address.hpp (modify), src/net/address.cpp (modify)  Dep: P082
  SocketAddress { variant<SocketAddressV4, SocketAddressV6> }. Family(), Port(), ToSockAddr().
  Verify: both families work

P084 | DNS resolution (getaddrinfo)
  File: include/net/address.hpp (modify), src/net/address.cpp (modify)  Dep: P083
  Result<SocketAddress> ResolveHost(host, port).
  Verify: resolve "localhost"

P085 | "host:port" string parser
  File: include/net/address.hpp (modify), src/net/address.cpp (modify)  Dep: P084
  ParseAddressString(input). Handles IPv6 [::1]:port.
  Verify: "[::1]:8080" and "127.0.0.1:9090"

P086 | TcpSocket RAII class
  File: include/net/socket.hpp (create), src/net/socket.cpp (create)  Dep: P084
  TcpSocket(FileDescriptor). Move-only. Release(), Close().
  Verify: create, move, close

P087 | TcpSocket::Create()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P086
  static Result<TcpSocket> Create(AF_INET, SOCK_STREAM|SOCK_NONBLOCK).
  Verify: Create() returns valid socket

P088 | TcpSocket::Bind()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P087
  Result<void> Bind(const SocketAddress&). Wraps ::bind().
  Verify: bind loopback:0

P089 | TcpSocket::Listen()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P088
  Result<void> Listen(int backlog = SOMAXCONN).
  Verify: EINVAL if not bound

P090 | TcpSocket::Accept()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P089
  Result<TcpSocket> Accept(SocketAddress*). Uses accept4(SOCK_NONBLOCK|SOCK_CLOEXEC).
  Verify: two-socket test

P091 | TcpSocket::Connect()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P090
  Result<void> Connect(const SocketAddress&). Non-blocking.
  Verify: returns WouldBlock

P092 | TcpSocket::Read()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P091
  Result<size_t> Read(MutByteSlice). Wraps ::read().
  Verify: read from connected pair

P093 | TcpSocket::Write()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P092
  Result<size_t> Write(ConstByteSlice). Wraps ::write().
  Verify: write to pipe, read back

P094 | SetOption template
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P093
  template<T> Result<void> SetOption(int level, int optname, T value).
  Verify: set/get TCP_NODELAY

P095 | GetOption template
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P094
  template<T> Result<T> GetOption(int level, int optname).
  Verify: round-trip

P096 | TCP_NODELAY helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P095
  SetTcpNoDelay(bool enable = true).
  Verify: getsockopt returns 1

P097 | TCP_QUICKACK helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P096
  SetTcpQuickAck(bool enable = true). Best-effort.
  Verify: succeeds or ENOPROTOOPT

P098 | SO_REUSEPORT helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P097
  SetReusePort(bool enable = true).
  Verify: two sockets bind same port

P099 | SO_REUSEADDR helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P098
  SetReuseAddr(bool enable = true).
  Verify: re-bind without EADDRINUSE

P100 | TCP_DEFER_ACCEPT helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P099
  SetTcpDeferAccept(int seconds = 1).
  Verify: setsockopt succeeds

P101 | TCP_FASTOPEN helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P100
  SetTcpFastOpen(int queue_len = 5).
  Verify: setsockopt succeeds

P102 | SO_KEEPALIVE with TCP keepalive params
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P101
  SetKeepAlive(bool, int idle=60, int interval=10, int count=3).
  Verify: setsockopt succeeds

P103 | SO_LINGER helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P102
  SetLinger(bool, int timeout_sec=0).
  Verify: setsockopt succeeds

P104 | TcpSocket::Shutdown()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P103
  Result<void> Shutdown(int how = SHUT_RDWR).
  Verify: shutdown on connected socket

P105 | LocalAddress() and RemoteAddress()
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P104
  getsockname / getpeername wrappers.
  Verify: after connect, both valid

P106 | Non-blocking connect with poll() fallback
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P105
  ConnectNonBlocking(addr). Uses poll() with timeout, checks SO_ERROR.
  Verify: connect succeeds

P107 | socketpair creation utility
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P106
  static Result<pair<TcpSocket, TcpSocket>> CreatePair(). socketpair(AF_UNIX).
  Verify: write one, read other

P108 | pipe creation utility
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P107
  Result<pair<FileDescriptor, FileDescriptor>> CreatePipe(). pipe2(O_NONBLOCK|O_CLOEXEC).
  Verify: read/write round-trip

P109 | eventfd creation utility
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P108
  Result<FileDescriptor> CreateEventFd(initval=0, flags=EFD_NONBLOCK|EFD_CLOEXEC).
  Verify: write 1, read returns 1

P110 | Socket unit test
  File: tests/unit/test_socket.cpp (create)  Dep: P109
  Create/bind/listen/accept/connect/read/write/socket options. Uses socketpair.
  Verify: ctest -R test_socket

P111 | Socket benchmark
  File: benchmarks/BM_Socket.cpp (create)  Dep: P110
  Create+close throughput, accept throughput, read/write latency.
  Verify: produces numbers

P112 | Socket error handling
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P111
  EAGAIN/EWOULDBLOCK -> WouldBlock. EINTR auto-retry in Read/Write.
  Verify: EINTR simulation

P113 | SocketOptions struct
  File: include/net/socket.hpp (modify)  Dep: P112
  struct SocketOptions { tcp_no_delay, reuse_port, keep_alive, tcp_defer_accept }. Apply().
  Verify: one-call Apply sets all

P114 | MakeListener helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P113
  static Result<TcpSocket> MakeListener(addr, opts). Creates, binds, listens, applies.
  Verify: one-liner creates configured listener

P115 | MakeConnection helper
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P114
  static Result<TcpSocket> MakeConnection(addr, opts).
  Verify: connects to listener

P116 | ScopedFd RAII helper
  File: include/net/socket.hpp (modify)  Dep: P115
  class ScopedFd { FileDescriptor fd_; ~ScopedFd() { close(fd_); } }.
  Verify: fd closed on scope exit

P117 | MSG_NOSIGNAL on writes
  File: src/net/socket.cpp (modify)  Dep: P116
  Use ::send(fd, data, len, MSG_NOSIGNAL) instead of ::write(). Prevents SIGPIPE.
  Verify: SIGPIPE not raised on write to closed socket

P118 | writev scatter-gather support
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P117
  Result<size_t> Writev(Slice<const ConstByteSlice>). Uses ::writev().
  Verify: single writev with 3 buffers

P119 | readv scatter-gather
  File: include/net/socket.hpp (modify), src/net/socket.cpp (modify)  Dep: P118
  Result<size_t> Readv(Slice<const MutByteSlice>). Uses ::readv().
  Verify: readv fills multiple buffers

P120 | Socket documentation with performance notes
  File: include/net/socket.hpp (modify)  Dep: P119
  Doxygen: each method's syscall cost, edge vs level-triggered considerations.
  Verify: documentation renders
```

### 1.2 Epoll Event Loop

```
P121 | Epoll class (epoll_create1 wrapper)
  File: include/net/epoll.hpp (create), src/net/epoll.cpp (create)  Dep: P028
  Epoll(), ~Epoll(), move-only. Constructor calls epoll_create1(EPOLL_CLOEXEC).
  Verify: Epoll() returns valid fd

P122 | Epoll::Add()
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P121
  Result<void> Add(FileDescriptor fd, uint32_t events, void* user_data).
  Verify: add fd, wait returns it

P123 | Epoll::Mod()
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P122
  Result<void> Mod(FileDescriptor fd, uint32_t events, void* user_data).
  Verify: modify events, new events take effect

P124 | Epoll::Del()
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P123
  Result<void> Del(FileDescriptor fd).
  Verify: unregistered fd no longer triggers

P125 | Epoll::Wait()
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P124
  Result<size_t> Wait(Slice<epoll_event>, int timeout_ms = -1).
  Verify: returns > 0 when events pending

P126 | EpollEvent struct (epoll_event wrapper)
  File: include/net/epoll.hpp (modify)  Dep: P125
  struct EpollEvent { uint32_t events; void* data; }. IsReadable, IsWritable, IsError, IsHup.
  Verify: flags decode correctly

P127 | Edge-triggered (EPOLLET) support
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P126
  AddEdgeTriggered / ModEdgeTriggered. EPOLLET auto-appended.
  Verify: epoll_event.events has EPOLLET

P128 | EPOLLONESHOT support
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P127
  AddOneShot / ModOneShot. Event fires once, must re-arm.
  Verify: fires once, needs re-arm

P129 | EPOLLRDHUP handling
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P128
  EPOLLRDHUP auto-appended. IsPeerClosed() checks RDHUP | HUP.
  Verify: peer close detected

P130 | WaitMany() stack-allocated batch
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P129
  template<size_t N=64> Result<size_t> WaitMany(int timeout_ms=-1).
  Verify: compiles with default arg

P131 | Event statistics tracking
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P130
  EpollStats { total_events, read_events, write_events, error_events, wakeups, max_batch }.
  Verify: stats increment correctly

P132 | Epoll::ResetStats()
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P131
  void ResetStats(). Zeroes all counters.
  Verify: after reset, all stats are 0

P133 | Userdata convention: ConnectionContext pointer
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P132
  user_data.ptr always points to ConnectionContext. Cast in handler.
  Verify: round-trip pointer

P134 | EpollTimer — timerfd integration
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P133
  class EpollTimer { ArmRelative(Duration); Disarm(); }. timerfd_create + epoll.
  Verify: timer fires after duration

P135 | Periodic timer support
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P134
  ArmPeriodic(Duration interval). itimerspec with interval.
  Verify: fires repeatedly

P136 | EpollWatch — eventfd wakeup
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P135
  class EpollWatch { Wakeup(); }. eventfd registered with epoll.
  Verify: wakeup causes epoll_wait to return

P137 | Epoll::TryWait() — non-blocking poll
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P136
  TryWait(Slice<epoll_event>). Wait with timeout=0.
  Verify: returns 0 when idle

P138 | Batch-full safety warning
  File: src/net/epoll.cpp (modify)  Dep: P137
  If Wait() returns events.size() (all slots full), LOG_WARN_ONCE.
  Verify: warning logged when batch full

P139 | Epoll::FdCount()
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P138
  size_t FdCount(). Internal counter incremented on Add, decremented on Del.
  Verify: count matches

P140 | Epoll unit test
  File: tests/unit/test_epoll.cpp (create)  Dep: P139
  Add/Mod/Del/Wait, edge-triggered reads, one-shot, RDHUP, timerfd.
  Verify: ctest -R test_epoll

P141 | Edge-triggered read drain loop
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P140
  DrainReads(fd, buffer). Reads in loop until EAGAIN.
  Verify: drain reads all available data

P142 | Edge-triggered write drain loop
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P141
  DrainWrites(fd, data). Writes in loop until all sent or EAGAIN.
  Verify: drain writes all data

P143 | EPOLLERR handling (SO_ERROR retrieval)
  File: src/net/epoll.cpp (modify)  Dep: P142
  On EPOLLERR, getsockopt(SO_ERROR). Map to ErrorCode.
  Verify: connect to unreachable port triggers

P144 | EPOLLHUP handling
  File: src/net/epoll.cpp (modify)  Dep: P143
  EPOLLHUP alone = clean close. EPOLLHUP + EPOLLIN = read then close.
  Verify: half-close (shutdown SHUT_WR) detected

P145 | Per-fd event interest tracking
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P144
  Internal flat_hash_map<FileDescriptor, uint32_t> of current events.
  Verify: Mod(fd) reads stored events

P146 | Epoll::Has(fd) check
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P145
  bool Has(FileDescriptor fd) const.
  Verify: after Add true, after Del false

P147 | Epoll::Dump() for debug
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P146
  string Dump(). Multi-line list of registered fds + events.
  Verify: output matches expected

P148 | EpollMultishot (auto-rearm pattern)
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P147
  For one-shot, auto-rearm after event dispatch. Reduces boilerplate.
  Verify: fires multiple times without manual re-arm

P149 | Epoll benchmark
  File: benchmarks/BM_Epoll.cpp (create)  Dep: P148
  Events/sec with 1/10/100/1000 fds. Edge vs level. Batch size impact.
  Verify: stable numbers

P150 | Error-level logging for epoll failures
  File: src/net/epoll.cpp (modify)  Dep: P149
  LOG_ERROR on unexpected epoll_wait errors. LOG_WARN on full batch.
  Verify: correct log messages

P151 | Timeout expiration callback
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P150
  SetOnTimeout(Duration, callback). When Wait returns 0, invoke.
  Verify: callback fires on timeout

P152 | Idle detection
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P151
  SetIdleCallback(Duration threshold, callback). If no events for threshold.
  Verify: callback fires after idle

P153 | Filter events by type after Wait
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P152
  ReadableEvents(), WritableEvents(), ErrorEvents() -> Slice<EpollEvent>.
  Verify: filtered views contain correct subsets

P154 | Adaptive batch sizing
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P153
  Start batch=64. If full, double (max 1024). If < half, halve (min 16).
  Verify: batch size adapts to load

P155 | EPOLLEXCLUSIVE for SO_REUSEPORT (Linux 4.5+)
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P154
  EPOLLEXCLUSIVE on listen sockets in multi-threaded mode.
  Verify: flag set when available

P156 | Epoll thread-safety debug checks
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P155
  In debug builds, assert same-thread operation. Store creation thread_id.
  Verify: cross-thread operation asserts

P157 | EpollMux — two-level priority multiplexer
  File: include/net/epoll.hpp (modify), src/net/epoll.cpp (modify)  Dep: P156
  AddHighPriority(fd, cb), AddLowPriority(fd, cb). High dispatches first.
  Verify: high-priority events first

P158 | Integration test: epoll echo server
  File: tests/integration/test_epoll_echo.cpp (create)  Dep: P157
  Echo server using epoll. Client connects, server echoes back.
  Verify: 1000 messages pass

P159 | io_uring migration plan comments
  File: include/net/epoll.hpp (modify)  Dep: P158
  Comments explaining how io_uring will replace epoll in Phase 4.
  Verify: comments render

P160 | Epoll documentation with state machine
  File: include/net/epoll.hpp (modify)  Dep: P159
  ASCII diagram: INIT -> ADDED -> MODIFIED -> DELETED. Edge-triggered read loop.
  Verify: diagram readable
```

### 1.3 Connection State Machine

```
P161 | ConnectionState enum (8 states)
  File: include/net/connection.hpp (create)  Dep: P028
  kFree, kAccepting, kConnecting, kReadingRequest, kParsingRequest, kConnectingUpstream,
  kForwardingRequest, kReadingResponse, kForwardingResponse, kClosing, kClosed.
  Verify: sizeof == 1

P162 | Valid transition table
  File: include/net/connection.hpp (modify), src/net/connection.cpp (create)  Dep: P161
  constexpr bool IsValidTransition(from, to). Lookup table.
  Verify: valid transitions pass, invalid fail

P163 | ToString(ConnectionState)
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P162
  const char* ToString(ConnectionState). For logging.
  Verify: all states have non-null strings

P164 | ConnectionContext struct
  File: include/net/connection.hpp (modify)  Dep: P163
  struct { state, client_fd, upstream_fd, id, start_time_ms, last_event_ms, flags, parser_state }.
  Verify: cache-line-friendly size

P165 | ConnectionFlags bitmask
  File: include/net/connection.hpp (modify)  Dep: P164
  kNode=0, kUpstreamConnected=1<<0, kRequestParsed=1<<1, kKeepAlive=1<<3, etc.
  Verify: flag operations work

P166 | ConnectionPool — pre-allocated contexts
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P165
  Acquire() -> ConnectionContext*, Release(ctx). ActiveCount(), Capacity().
  Verify: acquire/release cycle

P167 | ConnectionPool iterator (active only)
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P166
  begin(), end() over active connections. For graceful shutdown.
  Verify: for-range loop works

P168 | ConnectionId type
  File: include/net/connection.hpp (modify)  Dep: P167
  EDGE_STRONG_TYPEDEF(uint64_t, ConnectionId). Atomic incrementing counter.
  Verify: IDs unique and monotonic

P169 | Connection timeout tracking
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P168
  void Touch() { last_event_ms = NowMs(); }. IsTimedOut(timeout_ms).
  Verify: touch resets, idle times out

P170 | Connection idle timeout
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P169
  IsIdle(threshold_ms). Must be in idle-allowed state.
  Verify: non-idle is not idle

P171 | ConnectionHandler callback interface
  File: include/net/connection.hpp (modify)  Dep: P170
  virtual OnReadable(ctx), OnWritable(ctx), OnError(ctx, code), OnTimeout(ctx), OnClose(ctx).
  Verify: subclass compiles

P172 | Connection event dispatcher
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P171
  ConnectionDispatcher::Dispatch(ctx, event, handler). Routes based on state.
  Verify: correct handler called

P173 | Connection lifecycle hooks
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P172
  OnAccepted, OnConnected, OnRequestStart/End, OnResponseStart/End, OnClosed.
  Verify: hooks called in order

P174 | Connection close procedure
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P173
  CloseConnection(ctx). Shutdown + close both fds, release to pool, log.
  Verify: both fds closed

P175 | Half-close detection
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P174
  EPOLLRDHUP -> kClosing. Flush writes before full close.
  Verify: half-close triggers flush

P176 | Connection error handler
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P175
  HandleConnectionError(ctx, ErrorCode). Logs, transitions to kClosing.
  Verify: error leads to clean close

P177 | Connection reset counter with rate-limiting
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P176
  uint32_t reset_count. If > N resets in M seconds, blacklist IP.
  Verify: repeated resets trigger blacklist

P178 | Per-connection statistics
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P177
  ConnectionStats { bytes_read, bytes_written, start_time, end_time, request_count }.
  Verify: stats accumulate correctly

P179 | Connection watermarks for memory pressure
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P178
  Active > high_watermark: stop accepting. Resume below low.
  Verify: accept blocked at watermark

P180 | Connection Dump() for debugging
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P179
  string Dump(). "Conn#42 [READING_REQUEST] client=... upstream=...".
  Verify: readable format

P181 | Client/upstream address in context
  File: include/net/connection.hpp (modify)  Dep: P180
  SocketAddress client_addr, upstream_addr.
  Verify: populated correctly

P182 | ConnectionState transitions unit test
  File: tests/unit/test_connection.cpp (create)  Dep: P181
  Every valid transition. Invalid ones produce error. ToString.
  Verify: ctest -R test_connection

P183 | ConnectionPool stress test
  File: tests/unit/test_connection.cpp (modify)  Dep: P182
  Acquire all, release, random order, no leaks.
  Verify: passes under ASan

P184 | Timeout test
  File: tests/unit/test_connection.cpp (modify)  Dep: P183
  Create, touch, wait, verify timed out.
  Verify: timeout detection works

P185 | ConnectionPool benchmark
  File: benchmarks/BM_Connection.cpp (create)  Dep: P184
  Acquire/release throughput. Target: 100M+ ops/sec.
  Verify: runs

P186 | Per-IP rate limiter
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P185
  flat_hash_map<uint32_t, uint32_t> attempts. Sliding window.
  Verify: repeated attempts blocked

P187 | Epoll cleanup on connection close
  File: src/net/connection.cpp (modify)  Dep: P186
  On close: epoll_del client_fd, epoll_del upstream_fd, then close.
  Verify: closed fd removed from epoll

P188 | Connection migration stub (for Phase 3)
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P187
  MigrateConnection(ctx, target_epoll). Stub.
  Verify: compiles

P189 | Connection event coalescing
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P188
  Multiple events for same connection -> single dispatch.
  Verify: one dispatch per Wait()

P190 | ConnectionTimers — per-connection timeout management
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P189
  Add(id, duration), Cancel(id), Tick(), Expired() -> Vector.
  Verify: expired timers returned

P191 | Hierarchical timer wheel (O(1))
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P190
  Linux kernel-style timer wheel. ms resolution. 3 levels.
  Verify: 100k timers performant

P192 | Timer wheel with epoll tick
  File: src/net/connection.cpp (modify)  Dep: P191
  On epoll_wait return, timer_wheel.Tick(). Expired -> kClosing.
  Verify: idle connection times out

P193 | HTTP/1.1 keepalive support
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P192
  Reset state to kReadingRequest. Apply idle timeout.
  Verify: connection reused

P194 | Connection upgrade flag (WebSocket)
  File: include/net/connection.hpp (modify)  Dep: P193
  Connection: Upgrade sets kUpgraded flag. Bypass proxy.
  Verify: flag set correctly

P195 | Connection documentation
  File: include/net/connection.hpp (modify)  Dep: P194
  ASCII state machine, lifecycle flow, timeout behavior.
  Verify: doc renders
```

### 1.4 Buffer Management

```
P196 | BufferView type aliases
  File: include/mem/buffer.hpp (create)  Dep: P031
  using BufferView = Slice<const byte>; using MutBufferView = Slice<byte>.
  Verify: sizeof == 16

P197 | IOBuffer — fixed-capacity buffer
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (create)  Dep: P196
  IOBuffer(data, capacity). Capacity(), Size(), Empty(), Full(), Clear().
  Verify: basic operations

P198 | IOBuffer::Append()
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P197
  Result<size_t> Append(ConstByteSlice). Advances write cursor.
  Verify: append fills, then returns 0

P199 | IOBuffer::Consume()
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P198
  Result<size_t> Consume(size_t n). Advances read cursor.
  Verify: consume shrinks available

P200 | Readable() and Writable() slices
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P199
  ConstByteSlice Readable(), MutBufferView Writable().
  Verify: slices point correctly

P201 | IOBuffer::Prepend()
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P200
  Result<size_t> Prepend(ConstByteSlice). Write before read cursor.
  Verify: prepended data appears before

P202 | Compact/defragment
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P201
  void Compact(). Moves data to start, resets cursors.
  Verify: capacity used efficiently

P203 | IOBuffer::Reserve() (heap fallback)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P202
  Result<void> Reserve(size_t min_capacity). Reallocates if needed.
  Verify: Capacity() >= min_capacity

P204 | Read fd into buffer
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P203
  Result<size_t> ReadFrom(FileDescriptor). Reads into Writable().
  Verify: read from pipe fills buffer

P205 | Write buffer to fd
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P204
  Result<size_t> WriteTo(FileDescriptor). Writes Readable() to fd.
  Verify: write empties buffer

P206 | IoVector (iovec wrapper)
  File: include/mem/buffer.hpp (modify)  Dep: P205
  struct IoVector : iovec { IoVector(MutBufferView); IoVector(ConstByteSlice); }.
  Verify: conversion works

P207 | BufferChain — linked list of IOBuffers
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P206
  Append(), Splice(), Size(), Empty(), Clear(). For scatter-gather.
  Verify: chain of 3 buffers sums

P208 | BufferChain::ReadvFrom()
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P207
  Result<size_t> ReadvFrom(FileDescriptor). iovec from writable regions.
  Verify: readv fills multiple buffers

P209 | BufferChain::WritevTo()
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P208
  Result<size_t> WritevTo(FileDescriptor). iovec from readable regions.
  Verify: writev empties all buffers

P210 | Buffer watermark thresholds
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P209
  High/low watermarks. When Size() crosses, triggers flow control.
  Verify: watermarks observed

P211 | RingBuffer (SPSC, power-of-2)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P210
  template<T> RingBuffer { TryPush, TryPop, Size, Empty }. Mask instead of mod.
  Verify: push/pop cycle

P212 | Atomic RingBuffer (cross-thread SPSC)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P211
  template<T> AtomicRingBuffer. atomic head/tail. acquire/release ordering.
  Verify: producer + consumer threads

P213 | ReadBufferPool — pre-allocated read buffers
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P212
  Pre-allocated buffers. Acquire() -> IOBuffer*. Release(). No heap hot path.
  Verify: acquire returns, release recycles

P214 | WriteBufferPool
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P213
  Same as ReadBufferPool but for writing.
  Verify: acquire/release cycle

P215 | Buffer statistics tracking
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P214
  BufferStats { bytes_allocated, bytes_in_use, peak, acquire_count, release_count }.
  Verify: stats match

P216 | Zero-copy buffer transfer (steal)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P215
  Result<IOBuffer> Steal(). Transfer ownership without copying.
  Verify: source empty, target has data

P217 | Buffer unit test
  File: tests/unit/test_buffer.cpp (create)  Dep: P216
  Append/consume/compact/prepend, BufferChain, RingBuffer, pools.
  Verify: ctest -R test_buffer

P218 | BufferChain readv/writev test
  File: tests/unit/test_buffer.cpp (modify)  Dep: P217
  Pipe, ReadvFrom, WritevTo, compare.
  Verify: data integrity

P219 | Buffer benchmark
  File: benchmarks/BM_Buffer.cpp (create)  Dep: P218
  Append throughput (MB/s), consume, compact overhead, ring buffer latency.
  Verify: produces numbers

P220 | Geometric buffer growth
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P219
  When needed, double capacity (capped). Avoid O(n^2).
  Verify: 1K -> 2K -> 4K -> 8K

P221 | Aligned buffer allocation (for future io_uring)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P220
  CreateAligned(size, alignment=4096). Page-aligned data pointer.
  Verify: pointer is page-aligned

P222 | Memory-mapped buffer (mmap)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P221
  MmapBuffer(size_t). mmap MAP_ANONYMOUS | MAP_PRIVATE.
  Verify: mmap succeeds

P223 | Buffer recycling: Clear vs destroy docs
  File: include/mem/buffer.hpp (modify)  Dep: P222
  Clear() cheaper than destroy+create. Performance note.
  Verify: benchmark confirms

P224 | IOBuffer hexdump
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P223
  string Dump(size_t max=64). xxd-like format.
  Verify: readable hex+ASCII

P225 | Buffer ownership model docs
  File: include/mem/buffer.hpp (modify)  Dep: P224
  Who owns data, when copied vs shared, lifetime rules.
  Verify: doc clear
```

### 1.5 HTTP/1.1 Parser

```
P226 | HttpMethod enum
  File: include/http/method.hpp (create)  Dep: none
  GET, POST, PUT, DELETE, HEAD, OPTIONS, PATCH, CONNECT, TRACE. FromString/ToString.
  Verify: all round-trip

P227 | Fast method parse (first-char switch)
  File: include/http/method.hpp (modify), src/http/method.cpp (create)  Dep: P226
  Switch on first char: G->GET, P->POST/PUT/PATCH, D->DELETE, H->HEAD, etc.
  Verify: benchmark vs naive

P228 | HttpVersion enum
  File: include/http/request.hpp (create)  Dep: none
  kHttp10, kHttp11, kHttp20. FromString("HTTP/1.1").
  Verify: "HTTP/1.1" -> kHttp11

P229 | HttpStatusCode enum
  File: include/http/response.hpp (create)  Dep: none
  kOk=200, kNotFound=404, etc. ReasonPhrase(code) -> string_view.
  Verify: 200 -> "OK"

P230 | HttpHeader struct
  File: include/http/header.hpp (create)  Dep: none
  struct HttpHeader { string_view name; string_view value; }.
  Verify: comparison works

P231 | HttpHeaders ordered list
  File: include/http/header.hpp (modify), src/http/header.cpp (create)  Dep: P230
  Count(), Get(name), Add(name, value), Set(name, value), operator[].
  Verify: set/get/override works

P232 | Case-insensitive header lookup
  File: include/http/header.hpp (modify), src/http/header.cpp (modify)  Dep: P231
  Get() tolower each char. "Content-Type" matches "content-type".
  Verify: case-insensitive

P233 | HttpRequest struct
  File: include/http/request.hpp (modify)  Dep: P231
  method, path, query_string, version, headers, body. string_views into buffer.
  Verify: IsValid()

P234 | HttpResponse struct
  File: include/http/response.hpp (modify)  Dep: P233
  version, status_code, reason_phrase, headers, body. IsValid().
  Verify: IsValid()

P235 | ParserConfig struct
  File: include/http/parser.hpp (create)  Dep: P234
  max_header_size=8192, max_header_count=128, max_body_size=1MB.
  Verify: sensible defaults

P236 | Parser state enum
  File: include/http/parser.hpp (modify)  Dep: P235
  kStart, kMethod, kPath, kQuery, kVersion, kHeaderName, kHeaderValue, kBody, kDone, kError.
  Verify: sizeof == 1

P237 | HttpParser class
  File: include/http/parser.hpp (modify), src/http/parser.cpp (create)  Dep: P236
  state_, config_, out_request_. Feed(ConstByteSlice) -> Result<ParserState>. Reset().
  Verify: creates and resets

P238 | Request-line: method parsing
  File: src/http/parser.cpp (modify)  Dep: P237
  kStart: read token up to SP. "GET" -> kMethod, advance.
  Verify: "GET / HTTP/1.1\\r\\n" parses method

P239 | Request-line: path and query
  File: src/http/parser.cpp (modify)  Dep: P238
  After method SP, read to SP or '?'. Store path and optional query_string.
  Verify: "/search?q=hello" parses

P240 | Request-line: version parsing
  File: src/http/parser.cpp (modify)  Dep: P239
  Expect "HTTP/" major.minor. "HTTP/1.1" -> kHttp11. End with \r\n.
  Verify: triggers header state

P241 | Header-name parsing
  File: src/http/parser.cpp (modify)  Dep: P240
  Read to ':'. Trim. If \r\n at start (empty line), transition to kHeaderDone.
  Verify: "Content-Length:" stores name

P242 | Header-value parsing
  File: src/http/parser.cpp (modify)  Dep: P241
  Skip leading LWS. Read to \r\n. Store. Transition to next name.
  Verify: "Content-Length: 42\\r\n" stores "42"

P243 | Deprecated header continuation
  File: src/http/parser.cpp (modify)  Dep: P242
  Next line starts with SP/HT = continuation. Reject if config disallows.
  Verify: returns error

P244 | Header completion (empty line -> body)
  File: src/http/parser.cpp (modify)  Dep: P243
  Two \r\n in a row: end headers. Transition to body or done.
  Verify: transitions correctly

P245 | Body length detection
  File: src/http/parser.cpp (modify)  Dep: P244
  Content-Length or Transfer-Encoding: chunked. No body GET/HEAD/1xx/204/304.
  Verify: Content-Length:5 reads 5 body bytes

P246 | Chunked size parsing
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P245
  Parse chunk-size line (hex + \r\n). "5\\r\n" = 5 bytes.
  Verify: chunk-size parsed

P247 | Chunked body parsing
  File: src/http/parser.cpp (modify)  Dep: P246
  Read chunk-data + \r\n. Repeat until size=0. Trailing headers. Done.
  Verify: body reconstructed

P248 | Response status line parsing
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P247
  "HTTP/1.1 200 OK\\r\n" parses version, status_code, reason.
  Verify: status line parsed

P249 | Parser mode switch (request/response)
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P248
  enum ParserMode { kRequest, kResponse }.
  Verify: both modes work

P250 | Parser error codes
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P249
  kInvalidMethod, kInvalidVersion, kHeaderTooLong, kBodyTooLarge, etc.
  Verify: invalid input returns error

P251 | Incremental parsing (partial Feed)
  File: src/http/parser.cpp (modify)  Dep: P250
  Feed with partial data. Parser saves state and resumes.
  Verify: "GET " then "/" then " HTTP/1.1\\r\n" works

P252 | Parser metrics
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P251
  ParserMetrics { bytes_parsed, header_count, parsing_time, calls_to_feed }.
  Verify: metrics populated

P253 | Parser benchmark
  File: benchmarks/BM_Parser.cpp (create)  Dep: P252
  Feed throughput GB/s for various sizes. Compare vs picohttpparser. Target: 2+ GB/s.
  Verify: runs

P254 | Request parsing unit test
  File: tests/unit/test_parser.cpp (create)  Dep: P253
  GET, POST with body, all methods, edge cases.
  Verify: ctest -R test_parser

P255 | Response parsing test
  File: tests/unit/test_parser.cpp (modify)  Dep: P254
  200 OK, 404, 500 with body, 1xx informational.
  Verify: response struct correct

P256 | Chunked transfer encoding test
  File: tests/unit/test_parser.cpp (modify)  Dep: P255
  Single-chunk, multi-chunk, zero-chunk, trailing headers, invalid hex.
  Verify: all scenarios handled

P257 | Parser error handling test
  File: tests/unit/test_parser.cpp (modify)  Dep: P256
  Invalid method, too-long header, too-many headers, negative CL.
  Verify: each returns appropriate error

P258 | Incremental parsing test
  File: tests/unit/test_parser.cpp (modify)  Dep: P257
  Feed 1 byte at a time, 10 bytes. Compare result to single-feed.
  Verify: incremental == single

P259 | HTTP request/response formatter
  File: include/http/request.hpp (modify), include/http/response.hpp (modify),
        src/http/request.cpp (create), src/http/response.cpp (create)  Dep: P258
  FormatRequest/FormatResponse -> BufferChain.
  Verify: format -> parse -> compare round-trip

P260 | URL parser (absolute-form for proxy)
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P259
  struct Url { scheme, host, port, path, query }. ParseUrl().
  Verify: "http://example.com:8080/path?q=1" parses

P261 | Host header extraction
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P260
  Result<string_view> GetHost(const HttpHeaders&). Lowercased.
  Verify: "Host: Example.Com" -> "example.com"

P262 | Content-Length extraction
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P261
  Result<size_t> GetContentLength(const HttpHeaders&).
  Verify: "Content-Length: 42" -> 42

P263 | Hop-by-hop header blacklist
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P262
  IsHopByHopHeader(name). Connection, Keep-Alive, Transfer-Encoding, Upgrade, etc.
  Verify: "Connection" true, "Content-Type" false

P264 | Via header generation
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P263
  string GenerateViaHeader(). Returns "1.1 edge-proxy".
  Verify: matches expected

P265 | X-Forwarded-For handling
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P264
  AppendXForwardedFor(existing, client_ip). Creates or appends.
  Verify: "1.2.3.4" -> "1.2.3.4, 5.6.7.8"

P266 | Streaming mode (pause after headers)
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P265
  Parser pauses at kHeaderDone. Caller consumes body separately.
  Verify: streaming works

P267 | Connection: close detection
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P266
  IsConnectionClose(). Checks Connection: close or HTTP/1.0 without keep-alive.
  Verify: "Connection: close" -> true

P268 | Upgrade header detection
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P267
  IsUpgrade(). Checks Connection: Upgrade + Upgrade header.
  Verify: websocket upgrade detected

P269 | Expect: 100-continue detection
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P268
  IsExpectContinue(). If true, respond 100 or 417.
  Verify: "Expect: 100-continue" -> true

P270 | WebSocket accept key
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P269
  ComputeWebSocketAccept(key). SHA-1 + base64 of known GUID.
  Verify: known test vector

P271 | HTTP date formatter (RFC 7231)
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P270
  FormatHttpDate(time_t). "Tue, 12 May 2026 12:00:00 GMT".
  Verify: RFC-compliant

P272 | Connection header value tokenizer
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P271
  ParseConnectionTokens(value). Comma-separated, trimmed.
  Verify: "upgrade, keep-alive" -> [upgrade, keep-alive]

P273 | Fuzz test harness (libFuzzer)
  File: tests/fuzz/fuzz_parser.cpp (create)  Dep: P272
  Feed arbitrary bytes. No crashes, no infinite loops.
  Verify: 100k iterations ASan-clean

P274 | Fuzz target in CMake
  File: tests/fuzz/CMakeLists.txt (create)  Dep: P273
  add_executable with -fsanitize=fuzzer.
  Verify: cmake -DFUZZ=1 builds

P275 | Parser documentation
  File: include/http/parser.hpp (modify)  Dep: P274
  Limitations, performance, memory safety, RFC references (7230, 7231, 7540).
  Verify: doc ready
```

### 1.6 Event Loop & Proxy Pass-Through

```
P276 | EventLoop class
  File: include/net/event_loop.hpp (create), src/net/event_loop.cpp (create)  Dep: P127, P172
  Run(), Stop(), IsRunning(). Contains Epoll, ConnectionPool, Dispatcher.
  Verify: compiles and links

P277 | EventLoop::Run() main loop
  File: src/net/event_loop.cpp (modify)  Dep: P276
  while(running_) { epoll.Wait(); for event: dispatcher.Dispatch(); }.
  Verify: loop processes events

P278 | EventLoop::Tick() non-blocking run-once
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P277
  Tick(). epoll_wait timeout=0. For testing.
  Verify: returns 0 when idle

P279 | EventLoop::Stop() via eventfd
  File: src/net/event_loop.cpp (modify)  Dep: P278
  running_=false, wake epoll_wait via eventfd, drain events, close.
  Verify: Stop() within 100ms

P280 | OnAccept handler (accept loop)
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P279
  while true: accept4 -> allocate ctx -> epoll_add client. Stop on EAGAIN.
  Verify: handles 10k connections

P281 | Connection limits in OnAccept
  File: src/net/event_loop.cpp (modify)  Dep: P280
  ActiveCount >= MaxConnections: remove EPOLLIN. Resume below watermark.
  Verify: limit enforced

P282 | EventLoop::AddListener()
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P281
  MakeListener -> create ctx -> epoll_add.
  Verify: listener accepts connections

P283 | Async ConnectToUpstream()
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P282
  Create socket, connect non-blocking, epoll_add EPOLLOUT.
  Verify: connects async

P284 | Upstream connect completion
  File: src/net/event_loop.cpp (modify)  Dep: P283
  On writable: check SO_ERROR. 0 = established. Forward buffered request.
  Verify: success/failure handled

P285 | Request forwarding (client -> upstream)
  File: src/net/event_loop.cpp (modify)  Dep: P284
  On client readable: read, parse, create upstream request, forward headers.
  Verify: request reaches upstream

P286 | Upstream request formatting
  File: src/net/event_loop.cpp (modify)  Dep: P285
  Copy method/path, filter hop-by-hop headers, add Via, X-Forwarded-For.
  Verify: modified request sent

P287 | Response forwarding (upstream -> client)
  File: src/net/event_loop.cpp (modify)  Dep: P286
  On upstream readable: read, parse, forward response headers + body.
  Verify: client receives response

P288 | Response header modification
  File: src/net/event_loop.cpp (modify)  Dep: P287
  Filter hop-by-hop response headers. Add Via. Handle keep-alive.
  Verify: hop-by-hop removed

P289 | Streaming body forwarding (no buffering)
  File: src/net/event_loop.cpp (modify)  Dep: P288
  Forward body bytes as they arrive. Read from upstream, write to client.
  Verify: 100MB body with small memory

P290 | Write buffering for slow clients
  File: src/net/event_loop.cpp (modify)  Dep: P289
  If EAGAIN: buffer remaining. Register EPOLLOUT. On writable: flush.
  Verify: slow client buffered

P291 | Read buffering for slow upstream
  File: src/net/event_loop.cpp (modify)  Dep: P290
  If EAGAIN: stop reading. Wait for next EPOLLIN.
  Verify: partial reads handled

P292 | Keep-alive connection reuse
  File: src/net/event_loop.cpp (modify)  Dep: P291
  After response fully sent, if keepalive: reset to kReadingRequest.
  Verify: second request on same connection

P293 | Client disconnection handling
  File: src/net/event_loop.cpp (modify)  Dep: P292
  EPOLLRDHUP or read=0: close upstream, clean up.
  Verify: disconnect cleans

P294 | Upstream disconnection handling
  File: src/net/event_loop.cpp (modify)  Dep: P293
  Partial response: close. Done: keep client if keepalive.
  Verify: handled

P295 | Timeout handler integration
  File: src/net/event_loop.cpp (modify)  Dep: P294
  Timer tick: check connections, close timed-out. Send 408/504.
  Verify: idle connection closed

P296 | 502 Bad Gateway on upstream failure
  File: src/net/event_loop.cpp (modify)  Dep: P295
  Upstream connect fails -> 502. Minimal body.
  Verify: client receives 502

P297 | 504 Gateway Timeout on upstream timeout
  File: src/net/event_loop.cpp (modify)  Dep: P296
  Upstream read times out -> 504.
  Verify: timeout produces 504

P298 | 503 Service Unavailable on overload
  File: src/net/event_loop.cpp (modify)  Dep: P297
  Connection pool exhausted -> 503.
  Verify: overload produces 503

P299 | Error page response helper
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P298
  SendErrorResponse(ctx, code, message). Minimal HTML.
  Verify: error page sent

P300 | Upstream connection pooling
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P299
  Pool idle upstream connections. Reuse instead of new.
  Verify: pooled connections reused

P301 | Round-robin load balancing
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P300
  Multiple upstream addresses. Round-robin. Mark failed, try next.
  Verify: requests distributed

P302 | Health checking for upstreams
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P301
  Periodic HEAD /. N failures -> mark down. Retry after interval.
  Verify: unhealthy removed

P303 | Access logging (Apache combined format)
  File: src/net/event_loop.cpp (modify)  Dep: P302
  remote_ip - user [date] "method path" status bytes "referrer" "ua".
  Verify: log lines match

P304 | TLS termination stub
  File: include/net/event_loop.hpp (modify)  Dep: P303
  TlsConfig struct. Placeholder for Phase 5.
  Verify: stub compiles

P305 | Integration test: single-threaded proxy
  File: tests/integration/test_proxy_basic.cpp (create)  Dep: P304
  Start proxy on random port, echo upstream, send request through.
  Verify: e2e test passes

P306 | Proxy keep-alive test
  File: tests/integration/test_proxy_basic.cpp (modify)  Dep: P305
  Multiple requests on same connection.
  Verify: 10 requests each correct

P307 | Large body test (10MB)
  File: tests/integration/test_proxy_basic.cpp (modify)  Dep: P306
  10MB body through proxy. sha256 match.
  Verify: data integrity

P308 | Concurrent connections (100 clients)
  File: tests/integration/test_proxy_concurrent.cpp (create)  Dep: P307
  100 concurrent clients. All receive correct response.
  Verify: 100 concurrent succeed

P309 | Proxy error handling tests
  File: tests/integration/test_proxy_errors.cpp (create)  Dep: P308
  502, 504, 503, 400 scenarios.
  Verify: each produces correct code

P310 | Single-threaded proxy benchmark
  File: benchmarks/BM_Proxy.cpp (create)  Dep: P309
  Requests/sec, P50/P90/P99 latency. Target: 50k+ req/s single core.
  Verify: produces numbers

P311 | Read buffer per connection
  File: src/net/event_loop.cpp (modify)  Dep: P310
  Each context gets read buffer from ReadBufferPool.
  Verify: buffer attached

P312 | Write buffer per connection
  File: src/net/event_loop.cpp (modify)  Dep: P311
  Each context gets write buffer.
  Verify: buffer attached

P313 | Stream parse on the fly
  File: src/net/event_loop.cpp (modify)  Dep: P312
  As data arrives, feed parser. When headers done, forward. Body streamed.
  Verify: zero-buffer body streaming

P314 | Per-state connection timeouts
  File: src/net/event_loop.cpp (modify)  Dep: P313
  Accept 2s, Connect 10s, ReadRequest 30s, ReadResponse 30s, Idle 60s.
  Verify: per-state timeouts work

P315 | PROXY protocol v1 support
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P314
  On accept, detect PROXY header. Parse client_addr.
  Verify: PROXY header parsed

P316 | IP transparency (TPROXY) stub
  File: include/net/event_loop.hpp (modify)  Dep: P315
  Stub for preserving original client IP.
  Verify: compiles

P317 | Event loop statistics
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P316
  EventLoopStats { connections_accepted, closed, proxied, errors, bytes }.
  Verify: stats increment

P318 | EventLoop::DumpStats()
  File: src/net/event_loop.cpp (modify)  Dep: P317
  Human-readable multi-line stats.
  Verify: readable output

P319 | Signal handling via signalfd
  File: src/net/event_loop.cpp (modify)  Dep: P318
  signalfd registered with epoll. SIGINT/SIGTERM -> graceful stop.
  Verify: Ctrl-C triggers stop

P320 | signalfd integration method
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P319
  AddSignalHandler(signum). Creates signalfd, adds to epoll.
  Verify: kill -TERM triggers handler

P321 | Wire main.cpp to EventLoop
  File: src/main.cpp (modify)  Dep: P320
  Parse config -> Create EventLoop -> AddListener -> Signals -> Run().
  Verify: proxy runs and accepts

P322 | --version flag
  File: src/main.cpp (modify)  Dep: P321
  --version from version.hpp.
  Verify: ./edge_proxy --version prints

P323 | --config <path> flag
  File: src/main.cpp (modify)  Dep: P322
  Load config file from path.
  Verify: --config loads settings

P324 | Daemonization (--daemon)
  File: include/core/config.hpp (modify), src/main.cpp (modify)  Dep: P323
  fork() to background. Redirect stdio to /dev/null. Write PID file.
  Verify: --daemon returns, process runs

P325 | PID file management
  File: include/core/config.hpp (modify), src/main.cpp (modify)  Dep: P324
  Write PID, check existing on startup, remove on shutdown.
  Verify: PID created/removed

P326 | Graceful shutdown with connection drain
  File: src/net/event_loop.cpp (modify)  Dep: P325
  Stop accepting, drain timeout, in-flight complete, force close.
  Verify: requests complete

P327 | --shutdown-timeout config
  File: include/core/config.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P326
  Configurable drain timeout in seconds.
  Verify: timeout forces close

P328 | Lifecycle integration test
  File: tests/integration/test_proxy_lifecycle.cpp (create)  Dep: P327
  Start, verify listening, send request, SIGTERM, graceful shutdown.
  Verify: lifecycle passes

P329 | Memory usage tracking
  File: src/net/event_loop.cpp (modify)  Dep: P328
  Total memory for buffers, contexts, pools. Log at startup.
  Verify: memory logged

P330 | malloc_trim after connection burst
  File: src/net/event_loop.cpp (modify)  Dep: P329
  After large burst, call malloc_trim(0). Phase 1 heap.
  Verify: RSS drops
```

### Folder Tree After Phase 1 (P330)

```
edge-proxy/
├── include/
│   ├── core/     (types.hpp, platform.hpp, error.hpp, logger.hpp, config.hpp, version.hpp.in)
│   ├── net/      (address.hpp, socket.hpp, epoll.hpp, connection.hpp, event_loop.hpp)
│   ├── http/     (method.hpp, header.hpp, request.hpp, response.hpp, parser.hpp)
│   ├── mem/      (buffer.hpp, slab.hpp, arena.hpp, pool.hpp)
│   ├── sync/     (spsc.hpp, thread_pool.hpp, affinity.hpp)
│   ├── io/       (io_uring.hpp, xdp.hpp)
│   ├── simd/     (scan.hpp)
│   └── telemetry/ (metrics.hpp, latency.hpp)
├── src/
│   ├── main.cpp
│   ├── core/     (error.cpp, logger.cpp, config.cpp)
│   ├── net/      (address.cpp, socket.cpp, epoll.cpp, connection.cpp, event_loop.cpp)
│   ├── http/     (method.cpp, header.cpp, request.cpp, response.cpp, parser.cpp)
│   ├── mem/      (buffer.cpp)
│   ├── sync/     (spsc.cpp)
│   ├── io/       (io_uring.cpp)
│   ├── simd/     (scan.cpp)
│   └── telemetry/ (metrics.cpp)
├── tests/
│   ├── unit/     (test_error.cpp, test_logger.cpp, test_config.cpp, test_socket.cpp,
│   │              test_epoll.cpp, test_connection.cpp, test_buffer.cpp, test_parser.cpp)
│   ├── integration/ (test_epoll_echo.cpp, test_proxy_basic.cpp, test_proxy_concurrent.cpp,
│   │                  test_proxy_errors.cpp, test_proxy_lifecycle.cpp)
│   └── fuzz/     (fuzz_parser.cpp)
├── benchmarks/   (BM_Logger.cpp, BM_Socket.cpp, BM_Epoll.cpp, BM_Connection.cpp,
│                  BM_Buffer.cpp, BM_Parser.cpp, BM_Proxy.cpp)
├── scripts/
├── cmake/
└── .github/workflows/
```

---


## Phase 2: Memory Mastery — Zero-Allocation & Zero-Copy
**P331–P510 | 180 programs | Eliminate heap allocation in the hot path. Every byte pre-allocated at startup.**

---

### 2.1 Slab Allocator

```
P331 | SlabBlock — contiguous memory block
  File: include/mem/slab.hpp (create), src/mem/slab.cpp (create)  Dep: P035
  struct SlabBlock { byte* data; size_t size; size_t free_count; SlabBlock* next; }. Aligned via mmap.
  Verify: cache-line aligned

P332 | Slab class with free list
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P331
  Slab(object_size, block_size=8192). Allocate() -> void*, Free(void*). Intrusive free list.
  Verify: allocate returns aligned, free returns to pool

P333 | Slab::Allocate() fast path
  File: src/mem/slab.cpp (modify)  Dep: P332
  Free list non-empty: pop head, return O(1). Empty: allocate new block, build free list.
  Verify: 1000 distinct objects

P334 | Slab::Free() — return to free list
  File: src/mem/slab.cpp (modify)  Dep: P333
  Push to free list head. O(1). No zeroing.
  Verify: free then allocate returns same pointer

P335 | Slab::FreeAll() — reset entire slab
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P334
  Rebuild free list from all blocks. O(n).
  Verify: after FreeAll, all objects available

P336 | SlabStats
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P335
  SlabStats { object_size, block_size, allocated_objects, free_objects, total_blocks, total_memory, waste }.
  Verify: stats reflect actual state

P337 | Canary overflow detection (debug)
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P336
  Canary bytes before/after objects. Verify on Free().
  Verify: overflow triggers assert

P338 | Slab::Contains() pointer validation
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P337
  bool Contains(const void*). Checks if pointer in any block.
  Verify: valid=true, invalid=false

P339 | Memory zeroing policy
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P338
  enum ZeroPolicy { kNone, kOnAllocate, kOnFree, kBoth }. kNone in Release.
  Verify: policy respected

P340 | Slab::Grow()
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P339
  Result<void> Grow(size_t extra=0). Adds another block, expands free list.
  Verify: capacity increases

P341 | Block reuse (memory recycling)
  File: src/mem/slab.cpp (modify)  Dep: P340
  Fully freed block: unmap and release. Keep one empty block as hot cache.
  Verify: freed block unmapped

P342 | Slab::ShrinkToFit()
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P341
  Releases completely empty blocks.
  Verify: empty blocks removed

P343 | Prefetch in Allocate hot path
  File: src/mem/slab.cpp (modify)  Dep: P342
  __builtin_prefetch next free pointer to reduce cache misses.
  Verify: benchmark improvement

P344 | TypedSlab<T> wrapper
  File: include/mem/slab.hpp (modify)  Dep: P343
  template<typename T> TypedSlab { T* Allocate(); void Free(T*); }.
  Verify: TypedSlab<ConnectionContext> works

P345 | Slab::BulkAllocate()
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P344
  Result<Slice<T>> BulkAllocate(size_t count). Contiguous objects.
  Verify: bulk returns contiguous

P346 | Slab benchmark (vs malloc)
  File: benchmarks/BM_Slab.cpp (create)  Dep: P345
  Allocate/free ops/sec for 64B objects. Target: 10x faster than malloc.
  Verify: shows speedup

P347 | Non-thread-safety debug assert
  File: tests/unit/test_slab.cpp (create)  Dep: P346
  Cross-thread use fires assert in debug.
  Verify: assert fires

P348 | Overflow detection with canaries
  File: tests/unit/test_slab.cpp (modify)  Dep: P347
  Overwrite beyond object, verify assert.
  Verify: overflow detected

P349 | Various object sizes (8, 16, 32, 64, 128, 256, 512)
  File: tests/unit/test_slab.cpp (modify)  Dep: P348
  All sizes work correctly.
  Verify: ctest -R test_slab passes

P350 | Slab::Dump()
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P349
  Block layout, free list state, stats.
  Verify: readable output
```

### 2.2 Arena Allocator

```
P351 | Arena class (bump allocator)
  File: include/mem/arena.hpp (create), src/mem/arena.cpp (create)  Dep: P035
  Arena(size_t capacity). Allocate(size) -> void*. Reset(). Bump pointer: ptr += size.
  Verify: allocate bumps pointer

P352 | Allocate() with alignment
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P351
  Allocate(size, alignment = alignof(max_align_t)). Aligns pointer before bump.
  Verify: returned pointer aligned

P353 | Arena alignment padding tracking
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P352
  Track bytes lost to alignment padding. Report in stats.
  Verify: padding > 0 when misaligned

P354 | Arena::Reset()
  File: src/mem/arena.cpp (modify)  Dep: P353
  Reset pointer to start. No zeroing (caller responsible).
  Verify: after reset, arena reusable

P355 | Arena::Contains()
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P354
  bool Contains(const void*).
  Verify: valid=true, invalid=false

P356 | Arena::Available()
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P355
  size_t Available(). capacity - (ptr - start).
  Verify: shrinks after allocate

P357 | Arena growth (mmap overflow)
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P356
  If not enough space, mmap new block. Chain blocks.
  Verify: overflow handled

P358 | MmapArena
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P357
  MmapArena(capacity). mmap MAP_ANONYMOUS | MAP_PRIVATE. MADV_FREE on reset.
  Verify: mmap arena works

P359 | Arena watermark monitoring
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P358
  Watermark at 80% of capacity. LOG_WARN when exceeded.
  Verify: warning at 80%

P360 | PerThreadArena
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P359
  PerThreadArena { static Arena* Get(); }. thread_local instance.
  Verify: each thread gets independent arena

P361 | Typed Arena::Allocate<T>()
  File: include/mem/arena.hpp (modify)  Dep: P360
  template<T> T* Allocate(size_t count = 1). Typed, aligned. No constructor.
  Verify: T* returned

P362 | Arena::Duplicate(string_view)
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P361
  string_view Duplicate(string_view). Allocates copy in arena.
  Verify: copy retains content

P363 | Arena benchmark
  File: benchmarks/BM_Arena.cpp (create)  Dep: P362
  Allocate throughput vs malloc. Target: 50x faster for small allocs.
  Verify: speedup

P364 | Arena unit test
  File: tests/unit/test_arena.cpp (create)  Dep: P363
  Various sizes, alignment, reset, re-use.
  Verify: ctest -R test_arena passes

P365 | Arena::Dump()
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P364
  Block list, usage, available, waste.
  Verify: readable output

P366 | ArenaGuard (auto reset at scope exit)
  File: include/mem/arena.hpp (modify)  Dep: P365
  ArenaGuard { Arena* arena_; ~ArenaGuard() { arena_->Reset(); } }.
  Verify: reset on scope exit

P367 | ArenaSlab — slab from arena
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P366
  Slab that gets its blocks from an Arena instead of malloc.
  Verify: ArenaSlab allocates from arena

P368 | Arena-backed string pool
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P367
  StringPool { string_view Intern(string_view); }. Dedup via hashtable + arena storage.
  Verify: same string returns same pointer

P369 | Arena memory pressure callback
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P368
  SetPressureCallback(threshold_bytes, callback). Fires when Used() > threshold.
  Verify: callback fires

P370 | Cross-arena pointer validation (debug)
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P369
  In debug, Allocate() checks magic footer for use-after-reset.
  Verify: use-after-reset detected

P371 | Geometric arena chain growth
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P370
  New block size = max(min_growth, current_total * growth_factor). Default growth factor 2.0.
  Verify: second block is 2x first

P372 | Arena::FreeLast()
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P371
  void FreeLast(size_t). Decrement pointer by size. For temporaries.
  Verify: pointer moves back

P373 | Arena ownership docs
  File: include/mem/arena.hpp (modify)  Dep: P372
  Arena not thread-safe. Each thread owns its arena. Reset reclaims all.
  Verify: doc renders

P374 | Arena overflow action
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P373
  enum OverflowAction { kPanic, kGrow, kReturnNull }.
  Verify: action respected

P375 | Phase 2 memory model docs
  File: AGENTS.md (modify)  Dep: P374
  Hot path: Slab for fixed-size objects, Arena for variable-size. No malloc/free.
  Verify: doc clear
```

### 2.3 Connection Pool Optimization

```
P376 | ConnectionPool uses TypedSlab
  File: src/net/connection.cpp (modify)  Dep: P344, P166
  Replace vector<ConnectionContext> with TypedSlab<ConnectionContext>.
  Verify: pool still works, zero heap

P377 | Pool pre-warming at startup
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P376
  PreWarm(size_t count). Pre-allocates count contexts in slab.
  Verify: Acquire after pre-warm has zero latency

P378 | Pool watermark callback
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P377
  SetHighWatermarkCallback(count, fn). Fires when active > threshold.
  Verify: callback fires

P379 | Per-pool statistics
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P378
  PoolStats { capacity, active, peak, hits, misses }.
  Verify: stats accurate

P380 | Cache line alignment for ConnectionContext
  File: include/net/connection.hpp (modify)  Dep: P379
  EDGE_CACHE_ALIGNED on ConnectionContext. Prevents false sharing.
  Verify: sizeof padded to cache line

P381 | Zero-on-acquire for security
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P380
  On Acquire, zero context (memset). Configurable ZeroPolicy.
  Verify: old data not present

P382 | Pre-warm + acquire latency test
  File: tests/unit/test_connection.cpp (modify)  Dep: P381
  Pre-warm, acquire all, measure latency. Compare vs non-pre-warmed.
  Verify: pre-warmed faster

P383 | Pool size from config
  File: include/core/config.hpp (modify)  Dep: P382
  --max-connections N. Pass to ConnectionPool constructor.
  Verify: pool respects config

P384 | Pool diagnostics
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P383
  PoolDiagnostics() -> string. Active/idle/peak counts.
  Verify: readable

P385 | EventLoop uses pool watermarks
  File: src/net/event_loop.cpp (modify)  Dep: P384
  High watermark hit -> LOG_WARN, consider 503.
  Verify: watermarks used

P386 | Pool fragmentation tracking
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P385
  Slab free list fragmentation. Report if > threshold.
  Verify: fragmentation reported

P387 | Pool under high churn
  File: tests/unit/test_connection.cpp (modify)  Dep: P386
  100k acquire/release cycles. No memory growth.
  Verify: stable RSS

P388 | Bulk acquire/release
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P387
  AcquireBatch(count) -> Slice<ConnectionContext*>. ReleaseBatch().
  Verify: bulk ops faster

P389 | Pool sizing docs
  File: include/net/connection.hpp (modify)  Dep: P388
  Recommendation: MaxConnections = worker_threads * 1024.
  Verify: doc renders

P390 | Pool vs malloc benchmark
  File: benchmarks/BM_Connection.cpp (modify)  Dep: P389
  Pool acquire/release vs malloc/free for ConnectionContext. Target: 20x faster.
  Verify: speedup
```

### 2.4 Buffer Pool Optimization

```
P391 | ReadBufferPool uses Slab
  File: src/mem/buffer.cpp (modify)  Dep: P213, P344
  ReadBufferPool uses TypedSlab for buffer metadata + Arena for data.
  Verify: zero heap in hot path

P392 | WriteBufferPool uses Slab
  File: src/mem/buffer.cpp (modify)  Dep: P391
  Same as ReadBufferPool pattern.
  Verify: zero heap in hot path

P393 | Buffer pool pre-warming
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P392
  PreWarm(count). Pre-allocate buffers.
  Verify: Acquire after pre-warm instant

P394 | Zero-copy transfer between pools
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P393
  TransferBuffer(from_pool, to_pool, buffer). Moves without copy.
  Verify: buffer moves

P395 | Buffer compaction on return
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P394
  On Release, Compact() the buffer to minimize fragmentation.
  Verify: released buffer compacted

P396 | Buffer pool stats
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P395
  BufferPoolStats { total_buffers, active, peak, total_bytes, active_bytes }.
  Verify: stats accurate

P397 | Buffer pool churn test
  File: tests/unit/test_buffer.cpp (modify)  Dep: P396
  Rapid acquire/release. Verify no growth.
  Verify: stable

P398 | Buffer pool config
  File: include/core/config.hpp (modify)  Dep: P397
  --buffer-pool-size, --buffer-size. Pass to pool constructors.
  Verify: config respected

P399 | Token-bucket flow control
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P398
  If pool < low watermark, throttle upstream reads. Resume at high.
  Verify: throttling works

P400 | Buffer pool vs malloc benchmark
  File: benchmarks/BM_Buffer.cpp (modify)  Dep: P399
  Pool acquire/release vs malloc/free for 64KB buffers.
  Verify: speedup

P401 | Buffer poisoning (debug)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P400
  Fill data with 0xAA on acquire. Detect use of uninitialized data.
  Verify: uninit read caught

P402 | SpliceBuffer struct
  File: include/mem/buffer.hpp (modify)  Dep: P401
  struct SpliceBuffer { int pipe_fd[2]; }. For use with splice() syscall.
  Verify: struct works

P403 | Pipe buffer pool
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P402
  Pre-allocated pipe pairs for zero-copy forwarding.
  Verify: pipe pool works

P404 | Buffer pool architecture docs
  File: include/mem/buffer.hpp (modify)  Dep: P403
  Ownership, zero-copy paths, pool sizing guidance.
  Verify: doc renders

P405 | Buffer integrity check (debug CRC32)
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P404
  On Release, CRC32 of buffer content matches stored checksum.
  Verify: integrity violation detected
```

### 2.5 Zero-Allocation Integration

```
P406 | Audit hot path for heap allocations
  File: AGENTS.md (modify)  Dep: P405
  List all functions in request path. Mark: heap yes/no.
  Verify: all hot path heap-free

P407 | Replace std::string with string_view + Arena in parser
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P361
  Parser uses Arena for temporary string storage. No std::string.
  Verify: parser allocates from arena

P408 | Replace std::vector with fixed array in parser headers
  File: include/http/parser.hpp (modify)  Dep: P407
  HttpHeaders uses fixed array of HttpHeader[max_header_count]. No vector.
  Verify: header count limited

P409 | ConnectionContext allocated from Slab
  File: src/net/event_loop.cpp (modify)  Dep: P376
  Context allocated from TypedSlab<ConnectionContext>.
  Verify: zero heap per connect

P410 | IOBuffer data from Arena
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P408
  IOBuffer data pointer sourced from Arena. Reserve() uses Arena growth.
  Verify: Arena-backed IOBuffers

P411 | Parser output from Arena
  File: src/http/parser.cpp (modify)  Dep: P409
  HttpRequest allocated from arena per connection. string_views into buffer.
  Verify: zero copy per parse

P412 | Remove std::function from hot path
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P411
  Replace std::function with raw function pointers or virtual calls.
  Verify: no std::function allocation

P413 | epoll_event.data.ptr uses Slab memory
  File: src/net/epoll.cpp (modify)  Dep: P412
  Ensure user_data pointers always reference slab-allocated objects.
  Verify: no dangling pointers

P414 | Remove std::make_shared from hot path
  File: (project-wide)  Dep: P413
  Replace shared_ptr with raw owning pointers (Arena owns lifetime).
  Verify: no shared_ptr allocate

P415 | Remove std::stringstream from logger hot path
  File: src/core/logger.cpp (modify)  Dep: P414
  Replace with snprintf to stack buffer.
  Verify: no allocation in log hot path

P416 | AllocationTracker (debug)
  File: include/mem/tracker.hpp (create), src/mem/tracker.cpp (create)  Dep: P415
  Global AllocationTracker. Counts allocations in hot path. Warns if non-zero.
  Verify: hot path shows 0 allocations

P417 | Zero-alloc CI test
  File: tests/integration/test_zero_alloc.cpp (create)  Dep: P416
  Start proxy, send 1000 requests. Assert allocation count = 0 after startup.
  Verify: CI catches regressions

P418 | Zero-alloc 100-continue path
  File: src/net/event_loop.cpp (modify)  Dep: P417
  Expect: 100-continue response uses pre-formatted response buffer.
  Verify: zero alloc

P419 | Pre-formatted error pages in arena
  File: src/net/event_loop.cpp (modify)  Dep: P418
  502, 503, 504 error pages pre-formatted at startup in arena.
  Verify: error pages pre-allocated

P420 | Pre-formatted HTTP date strings
  File: src/http/parser.cpp (modify)  Dep: P419
  Pre-compute Date header strings for next 60 seconds. Update every second.
  Verify: zero alloc per response

P421 | Heap allocation regression suite
  File: tests/integration/test_heap_allocation.cpp (create)  Dep: P420
  Suite that monitors malloc/free during operations. Fails if unexpected.
  Verify: regression suite passes

P422 | Zero-allocation guarantees docs
  File: AGENTS.md (modify)  Dep: P421
  After startup phase, zero heap allocations in request path.
  Verify: documented

P423 | Zero-alloc header forwarding
  File: src/net/event_loop.cpp (modify)  Dep: P422
  Forwarding uses pre-allocated write buffer, no string copy.
  Verify: zero alloc header forward

P424 | Config uses sorted vector + binary search
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P423
  Config uses sorted vector<pair<ConfigKey, ConfigValue>> instead of hash map.
  Verify: no alloc on Get()

P425 | Zero-alloc audit with Valgrind
  File: scripts/profile.sh (modify)  Dep: P424
  Script runs valgrind --tool=massif on proxy with test load.
  Verify: heap usage flat after startup
```

### 2.6 Zero-Copy Forwarding

```
P426 | splice() client to pipe
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P402
  SpliceFromClient: splice(client_fd, pipe_fd, size). No userspace copy.
  Verify: data reaches pipe

P427 | splice() pipe to upstream
  File: src/net/event_loop.cpp (modify)  Dep: P426
  SpliceToUpstream: splice(pipe_fd, upstream_fd, size).
  Verify: data reaches upstream

P428 | Zero-copy request forwarding
  File: src/net/event_loop.cpp (modify)  Dep: P427
  Forward request body using pipe splice instead of userspace buffers.
  Verify: zero-copy path active

P429 | Zero-copy response forwarding
  File: src/net/event_loop.cpp (modify)  Dep: P428
  Forward response body using pipe splice.
  Verify: zero-copy path active

P430 | Buffer fallback when splice fails
  File: src/net/event_loop.cpp (modify)  Dep: P429
  If splice returns ENOSYS or EINVAL, fall back to buffer copy.
  Verify: fallback works

P431 | Benchmark splice vs buffered
  File: benchmarks/BM_Proxy.cpp (modify)  Dep: P430
  Throughput and latency comparison: splice vs read/write for body.
  Verify: splice faster for large bodies

P432 | sendfile() for static files
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P431
  SendFile(ctx, FileDescriptor file_fd, off_t offset, size_t count). Uses sendfile().
  Verify: file sent to socket

P433 | Splice pipe pool config
  File: include/core/config.hpp (modify)  Dep: P432
  --splice-pipe-size, --max-splice-pipes. Configure pipe buffers.
  Verify: config respected

P434 | Zero-copy large body test
  File: tests/integration/test_proxy_basic.cpp (modify)  Dep: P433
  100MB body. Data integrity with and without splice. sha256 matches.
  Verify: data integrity

P435 | Zero-copy architecture docs
  File: AGENTS.md (modify)  Dep: P434
  Data path diagram: client -> pipe -> upstream (no userspace copy).
  Verify: doc renders
```

### 2.7 Memory Profiling & Introspection

```
P436 | MemoryUsage() tracking
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P354
  size_t MemoryUsed(). Total bytes from OS (all slabs + arenas).
  Verify: reports correct total

P437 | RSS monitoring thread
  File: include/mem/tracker.hpp (modify), src/mem/tracker.cpp (modify)  Dep: P436
  Background thread reads /proc/self/status VmRSS every 5s. Logs on change.
  Verify: RSS logged at intervals

P438 | Per-pool memory reporting
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P437
  PoolMemoryUsage() -> size_t. Reports memory used by each pool.
  Verify: accurate per-pool numbers

P439 | malloc_stats integration
  File: src/mem/tracker.cpp (modify)  Dep: P438
  Call malloc_stats() on SIGUSR2. Logs glibc heap stats.
  Verify: SIGUSR2 triggers heap dump

P440 | Memory leak detection hooks
  File: include/mem/tracker.hpp (modify), src/mem/tracker.cpp (modify)  Dep: P439
  On shutdown, assert all slab objects freed. Report leaked objects.
  Verify: leak detected
```

### 2.8 Advanced Memory Patterns

```
P441 | Object pool for HTTP parser
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P344
  TypedSlab<HttpParser> pool. Reuse parser objects instead of create/destroy.
  Verify: pool reuses parsers

P442 | Cache-friendly struct layout audit
  File: include/net/connection.hpp (modify)  Dep: P441
  Reorder ConnectionContext fields: hot data first, cold data last. Pack bools.
  Verify: sizeof reduced

P443 | Prefetching in accept loop
  File: src/net/event_loop.cpp (modify)  Dep: P442
  __builtin_prefetch next ConnectionContext before accept().
  Verify: benchmark improvement

P444 | Alignment tuning for hot globals
  File: include/core/platform.hpp (modify)  Dep: P443
  Cache-line-align global counters and frequently-accessed globals.
  Verify: alignment verified

P445 | Batch allocation for HTTP headers
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P444
  Arena::AllocateHeaders(count). Contiguous allocation for header array.
  Verify: contiguous memory

P446 | Memory barrier documentation
  File: AGENTS.md (modify)  Dep: P445
  Where memory barriers are needed, where they are not. Acquire/release semantics.
  Verify: doc clear

P447 | Hot/cold attribute annotation
  File: src/net/event_loop.cpp (modify)  Dep: P446
  Mark error paths and cold functions with EDGE_COLD. Improves icache.
  Verify: compiles with attributes

P448 | Branch prediction hints
  File: include/net/connection.hpp (modify)  Dep: P447
  EDGE_LIKELY/EDGE_UNLIKELY on hot path conditions.
  Verify: test compiles

P449 | Stack allocation for small buffers
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P448
  Use stack-allocated buffer for headers < 2KB. Fallback to pool for larger.
  Verify: stack used for small requests

P450 | Compiler optimization barriers
  File: include/core/platform.hpp (modify)  Dep: P449
  EDGE_COMPILER_BARRIER macro using asm volatile("" ::: "memory").
  Verify: compiles
```

### 2.9 NUMA & Huge Pages Deep Dive

```
P451 | Page size detection
  File: include/core/platform.hpp (modify), src/core/platform.cpp (create)  Dep: P450
  size_t GetPageSize(). Returns sysconf(_SC_PAGESIZE).
  Verify: returns 4096

P452 | Huge page size detection
  File: include/core/platform.hpp (modify), src/core/platform.cpp (modify)  Dep: P451
  size_t GetHugePageSize(). Reads /proc/meminfo Hugepagesize.
  Verify: returns 2048K

P453 | Huge page allocation for arena
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P452
  Arena can request 2MB huge pages via MAP_HUGETLB. Fallback to regular mmap.
  Verify: huge pages used when available

P454 | THP (Transparent Huge Pages) helper
  File: include/core/platform.hpp (modify)  Dep: P453
  bool IsTransparentHugePagesEnabled(). Checks /sys/kernel/mm/transparent_hugepage/enabled.
  Verify: detects THP state

P455 | MADV_HUGEPAGE advice
  File: src/mem/arena.cpp (modify)  Dep: P454
  madvise(MADV_HUGEPAGE) on arena blocks > 2MB. Kernel merges into THP.
  Verify: THP merges pages

P456 | MADV_COLD on idle memory
  File: src/mem/arena.cpp (modify)  Dep: P455
  On arena reset, madvise(MADV_COLD) hint to reclaim sooner.
  Verify: RSS drops faster

P457 | NUMA node count
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P472
  int GetNumaNodeCount(). Reads /sys/devices/system/node/.
  Verify: matches numactl

P458 | NUMA memory allocation stub
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P457
  AllocOnNumaNode(size_t size, int node). Uses libnuma if available.
  Verify: stub compiles

P459 | Huge pages config
  File: include/core/config.hpp (modify)  Dep: P458
  --huge-pages {off, transparent, explicit}. Default: transparent.
  Verify: config respected

P460 | Huge pages allocation test
  File: tests/unit/test_memory.cpp (create)  Dep: P459
  Allocate with huge pages. Verify alignment and size.
  Verify: ctest -R test_memory
```

### 2.10 Memory Safety & Hardening

```
P461 | Heap allocation guard page
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P460
  mmap with PROT_NONE guard page between arena blocks. Detect overflow.
  Verify: overflow causes segfault (expected in debug)

P462 | Double-free detection
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P461
  In debug, track freed pointers in hash set. Assert on double free.
  Verify: double free asserts

P463 | Slab integrity check
  File: include/mem/slab.hpp (modify), src/mem/slab.cpp (modify)  Dep: P462
  void IntegrityCheck(). Validates free list: no cycles, all pointers in range.
  Verify: check passes on valid state

P464 | Arena bounds checking (debug)
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P463
  In debug, add red zone after each allocation. Verify on next alloc.
  Verify: overwrite detected

P465 | Object reuse timeout detection
  File: include/net/connection.hpp (modify)  Dep: P464
  Tag freed objects with timestamp. If reused too quickly, possible use-after-free.
  Verify: detection works

P466 | Memory poisoning on free
  File: src/mem/slab.cpp (modify)  Dep: P465
  Fill freed memory with 0xDEADBEEF pattern. Detect use-after-free.
  Verify: use-after-free crashes in debug

P467 | Pool capacity safety limit
  File: include/mem/slab.hpp (modify)  Dep: P466
  Max total memory limit per slab. Panic if exceeded.
  Verify: limit enforced

P468 | OOM handling test
  File: tests/unit/test_memory.cpp (modify)  Dep: P467
  Exhaust pool, verify graceful OOM handling (error return, not crash).
  Verify: OOM returns error

P469 | Memory stats endpoint
  File: include/mem/tracker.hpp (modify), src/mem/tracker.cpp (modify)  Dep: P468
  GlobalMemoryStats() -> string. All pools, allocators, RSS, peak RSS.
  Verify: readable stats

P470 | Final memory model documentation
  File: AGENTS.md (modify)  Dep: P469
  Complete memory architecture: slab, arena, pools, zero-alloc guarantees.
  Verify: doc renders
```

### Folder Tree After Phase 2 (P470)

```
edge-proxy/
├── include/
│   ├── core/     (types.hpp, platform.hpp, error.hpp, logger.hpp, config.hpp, version.hpp.in)
│   ├── net/      (address.hpp, socket.hpp, epoll.hpp, connection.hpp, event_loop.hpp)
│   ├── http/     (method.hpp, header.hpp, request.hpp, response.hpp, parser.hpp)
│   ├── mem/      (slab.hpp, arena.hpp, pool.hpp, buffer.hpp, tracker.hpp)
│   ├── sync/     (spsc.hpp, thread_pool.hpp, affinity.hpp)
│   ├── io/       (io_uring.hpp, xdp.hpp)
│   ├── simd/     (scan.hpp)
│   └── telemetry/ (metrics.hpp, latency.hpp)
├── src/
│   ├── main.cpp
│   ├── core/     (error.cpp, logger.cpp, config.cpp, platform.cpp)
│   ├── net/      (address.cpp, socket.cpp, epoll.cpp, connection.cpp, event_loop.cpp)
│   ├── http/     (method.cpp, header.cpp, request.cpp, response.cpp, parser.cpp)
│   ├── mem/      (slab.cpp, arena.cpp, buffer.cpp, tracker.cpp)
│   ├── sync/     (spsc.cpp, thread_pool.cpp, affinity.cpp)
│   ├── io/       (io_uring.cpp)
│   ├── simd/     (scan.cpp)
│   └── telemetry/ (metrics.cpp)
├── tests/
│   ├── unit/     (+ test_slab.cpp, test_arena.cpp, test_memory.cpp)
│   ├── integration/ (+ test_zero_alloc.cpp, test_heap_allocation.cpp)
│   └── fuzz/
├── benchmarks/   (+ BM_Slab.cpp, BM_Arena.cpp)
├── scripts/
├── cmake/
└── .github/workflows/
```

---


## Phase 3: Extreme Concurrency — Thread-per-Core
**P471–P660 | 190 programs | Scale linearly across CPU cores without locks, mutexes, or atomic contention.**

---

### 3.1 Thread Pool & Worker Management

```
P471 | WorkerId type
  File: include/sync/thread_pool.hpp (modify)  Dep: P027
  EDGE_STRONG_TYPEDEF(uint32_t, WorkerId). kMainWorker = 0.
  Verify: strong typing works

P472 | WorkerContext struct
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P471
  struct WorkerContext { WorkerId id; Epoll epoll; ConnectionPool pool; Arena arena; pthread_t thread; }.
  Verify: each worker has isolated resources

P473 | ThreadPool class
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P472
  ThreadPool(size_t num_workers). GetWorker(WorkerId). WorkerCount().
  Verify: pool creates N workers

P474 | Worker thread start
  File: src/sync/thread_pool.cpp (modify)  Dep: P473
  void WorkerThread(WorkerContext* ctx). Runs EventLoop::Run() in thread.
  Verify: N threads running

P475 | Worker health monitoring
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P474
  Heartbeat every 100ms. IsWorkerAlive(WorkerId).
  Verify: heartbeat updates

P476 | Worker crash detection
  File: src/sync/thread_pool.cpp (modify)  Dep: P475
  If heartbeat stops, LOG_CRITICAL. Attempt restart (future).
  Verify: crash detected

P477 | Thread naming (pthread_setname_np)
  File: src/sync/thread_pool.cpp (modify)  Dep: P476
  Name threads "edge:wkr:0", "edge:wkr:1", etc.
  Verify: ps shows thread names

P478 | Worker startup barrier
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P477
  std::barrier. All workers reach barrier before Run().
  Verify: all workers start before proceeding

P479 | Graceful worker stop
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P478
  StopAll(). Each EventLoop::Stop() called. Join threads.
  Verify: all threads joined

P480 | Worker stop timeout
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P479
  StopAll(timeout_ms). If thread doesn't join in time, pthread_cancel.
  Verify: timeout handled

P481 | WorkerPool diagnostics
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P480
  Dump() -> string. List workers, states, thread IDs.
  Verify: readable

P482 | Worker-local random seed
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P481
  Each worker seeds with (worker_id ^ time ^ pid). For jitter.
  Verify: seeds differ

P483 | Worker-local config overrides
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P482
  Workers can have local config overrides (e.g., upstream weights).
  Verify: override works

P484 | Work-stealing stub
  File: include/sync/thread_pool.hpp (modify)  Dep: P483
  Stub for future work-stealing when one worker idle.
  Verify: compiles

P485 | Thread lifecycle unit test
  File: tests/unit/test_thread_pool.cpp (create)  Dep: P484
  Create pool, verify N threads, verify start, stop, join.
  Verify: ctest -R test_thread_pool

P486 | Worker crash isolation test
  File: tests/unit/test_thread_pool.cpp (modify)  Dep: P485
  Simulate worker crash (SIGSEGV). Verify others unaffected.
  Verify: crash isolated

P487 | Thread creation benchmark
  File: benchmarks/BM_ThreadPool.cpp (create)  Dep: P486
  Create/destroy pool of N threads. Measure latency.
  Verify: runs

P488 | Thread pool size from config
  File: include/core/config.hpp (modify), src/main.cpp (modify)  Dep: P487
  --workers N. Default: std::thread::hardware_concurrency().
  Verify: --workers 4 creates 4 threads

P489 | Worker auto-scaling stub
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P488
  Stub for adding/removing workers at runtime.
  Verify: compiles

P490 | Thread pool architecture docs
  File: include/sync/thread_pool.hpp (modify)  Dep: P489
  Shared-nothing design. Each worker owns its epoll, pool, arena.
  Verify: doc renders
```

### 3.2 CPU Affinity & Topology Discovery

```
P491 | CPU topology discovery
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P033
  CpuTopology { int sockets, cores_per_socket, threads_per_core }. DetectCpuTopology().
  Verify: matches lscpu

P492 | Online CPU list
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P491
  vector<int> GetOnlineCpus(). Reads /sys/devices/system/cpu/online.
  Verify: non-empty

P493 | Socket-associated CPUs
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P492
  vector<int> GetCpusForSocket(int socket_id).
  Verify: matches lscpu

P494 | Pin thread to CPU
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P493
  PinThreadToCpu(pthread_t, int cpu_id). Uses pthread_setaffinity_np.
  Verify: thread pinned to CPU

P495 | Pin thread to CPU set
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P494
  PinThreadToCpuSet(pthread_t, const cpu_set_t&).
  Verify: pinned to set

P496 | Auto-pinning strategy
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P495
  PinStrategy { kSpreadAcrossCores, kFillSocketFirst, kCompact }. AutoAssign().
  Verify: workers spread

P497 | NUMA node detection
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P496
  int GetNumaNodeForCpu(int cpu). Reads /sys/devices/system/node/.
  Verify: matches numactl

P498 | NUMA-aware pinning
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P497
  Assign workers within same NUMA node when possible.
  Verify: workers on same node

P499 | Hyperthread awareness
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P498
  Detect HT siblings. Prefer physical cores over logical.
  Verify: HT siblings detected

P500 | CPU isolation check
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P499
  bool IsCpuIsolated(int cpu). Checks isolcpus kernel cmdline.
  Verify: isolated detected

P501 | Pin thread to socket
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P500
  Pins to any CPU in a given NUMA node/socket.
  Verify: pinned to socket

P502 | Pin verification
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P501
  GetCurrentCpu() via sched_getcpu.
  Verify: returns correct CPU

P503 | Affinity integration with ThreadPool
  File: src/sync/thread_pool.cpp (modify)  Dep: P502
  On worker start, apply affinity based on strategy.
  Verify: workers pinned

P504 | Affinity config
  File: include/core/config.hpp (modify)  Dep: P503
  --pin-strategy {spread, fill-socket, compact}. --no-pin disables.
  Verify: --pin-strategy spread works

P505 | NUMA memory allocation stub
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P504
  AllocOnNumaNode(size_t, int node). Uses numa_alloc_onnode.
  Verify: stub compiles

P506 | CPU pinning test
  File: tests/unit/test_affinity.cpp (create)  Dep: P505
  Pin thread to specific CPU. Verify sched_getcpu matches.
  Verify: ctest -R test_affinity

P507 | Cross-NUMA benchmark
  File: benchmarks/BM_Numa.cpp (create)  Dep: P506
  Memory allocation + access latency: local vs remote NUMA node.
  Verify: local faster

P508 | NUMA topology dump
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P507
  DumpTopology() -> string. CPUs, NUMA nodes, cache info.
  Verify: readable

P509 | Affinity architecture docs
  File: include/sync/affinity.hpp (modify)  Dep: P508
  Pin strategy, NUMA awareness, cache topology.
  Verify: doc renders

P510 | Thread placement on NUMA-aware workers
  File: src/sync/thread_pool.cpp (modify)  Dep: P509
  Assign workers to fill one NUMA node before moving to next.
  Verify: workers packed on first NUMA node
```

### 3.3 Per-Thread Isolation

```
P511 | EventLoop owned by WorkerContext
  File: src/sync/thread_pool.cpp (modify)  Dep: P473, P276
  Each WorkerContext creates own EventLoop. No main thread loop.
  Verify: each thread has independent loop

P512 | ConnectionPool per-worker
  File: include/sync/thread_pool.hpp (modify)  Dep: P511
  ConnectionPool moved into WorkerContext.
  Verify: pools are separate

P513 | ReadBufferPool per-worker
  File: include/sync/thread_pool.hpp (modify)  Dep: P512
  Each worker has own ReadBufferPool.
  Verify: isolated pools

P514 | WriteBufferPool per-worker
  File: include/sync/thread_pool.hpp (modify)  Dep: P513
  Each worker has own WriteBufferPool.
  Verify: isolated pools

P515 | Arena per-worker
  File: include/sync/thread_pool.hpp (modify)  Dep: P514
  Each worker creates own Arena at startup.
  Verify: independent arenas

P516 | Slab allocators per-worker
  File: include/sync/thread_pool.hpp (modify)  Dep: P515
  TypedSlab<ConnectionContext> per worker.
  Verify: isolated slabs

P517 | Remove global logger contention
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P516
  AsyncLogWriter accepts from any thread via SPSC. No mutex.
  Verify: log write non-blocking

P518 | thread_local caches for hot data
  File: include/core/platform.hpp (modify)  Dep: P517
  thread_local CpuFeatures, random seed, etc.
  Verify: isolated

P519 | Verify no mutex in hot path
  File: src/net/event_loop.cpp (modify)  Dep: P518
  Search for std::mutex, pthread_mutex in hot path. Replace.
  Verify: zero mutexes

P520 | Per-worker stats aggregation
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P519
  Each worker tracks own stats. Global = sum over workers. Atomic-free.
  Verify: global stats accurate

P521 | SO_REUSEPORT listener per worker
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P511
  Each worker creates own TCP listener with SO_REUSEPORT on same port.
  Verify: all workers accept

P522 | Listener count = worker count
  File: src/main.cpp (modify)  Dep: P521
  main() creates N listeners (one per worker).
  Verify: N sockets on same port

P523 | SO_REUSEPORT distribution test
  File: tests/integration/test_reuseport.cpp (create)  Dep: P522
  10000 connections. Verify distribution across workers.
  Verify: roughly uniform

P524 | Per-worker connection counter
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P523
  Each worker tracks active count. Dump shows per-worker.
  Verify: counters accurate

P525 | Worker-local timer wheel
  File: include/sync/thread_pool.hpp (modify)  Dep: P191
  Timer wheel per worker. No cross-worker timer coordination.
  Verify: timers per-worker

P526 | Per-worker isolation under load
  File: tests/integration/test_worker_isolation.cpp (create)  Dep: P525
  Saturate one worker. Check other workers unaffected.
  Verify: isolation holds

P527 | Private vs shared benchmark
  File: benchmarks/BM_Isolation.cpp (create)  Dep: P526
  Private pools vs global pools with mutex. Throughput comparison.
  Verify: private faster

P528 | Worker-local HTTP parser cache
  File: include/sync/thread_pool.hpp (modify)  Dep: P527
  Reuse HttpParser instance per connection.
  Verify: parser reused

P529 | Remove atomic operations from hot path
  File: src/net/event_loop.cpp (modify)  Dep: P528
  Audit atomic ops. Replace with non-atomic if single-worker access.
  Verify: zero atomics in hot path

P530 | Per-worker buffer watermark
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P529
  Each worker has own buffer pool watermarks.
  Verify: per-worker watermarks

P531 | Per-worker load metric
  File: include/sync/thread_pool.hpp (modify)  Dep: P530
  float GetLoad(). active_connections / max_connections.
  Verify: load metric valid

P532 | Worker event loop epoch counter
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P531
  uint64_t epoch. Incremented each event loop iteration.
  Verify: monotonic

P533 | Cross-worker pointer isolation (debug)
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P532
  In debug, assert pointers only accessed by owning worker.
  Verify: cross-worker access asserts

P534 | Cross-worker contention benchmark
  File: benchmarks/BM_Contention.cpp (create)  Dep: P533
  Shared-nothing vs shared with mutex. Show throughput difference.
  Verify: shared-nothing wins

P535 | Shared-nothing architecture docs
  File: AGENTS.md (modify)  Dep: P534
  Each worker = "virtual server". Owns epoll, memory, connections.
  Verify: doc renders
```

### 3.4 Lock-Free Communication (SPSC)

```
P536 | SPSCQueue (Single-Producer Single-Consumer)
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P035
  template<T> SPSCQueue. TryPush, TryPop. Power-of-2 size, mask not mod.
  Verify: push/pop cycle

P537 | Blocking variants (WaitPush, WaitPop)
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P536
  BlockingPush, BlockingPop. Uses futex or eventfd.
  Verify: blocking push/pop

P538 | TryPush with timeout
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P537
  TryPushTimed(item, Duration). Uses eventfd + epoll.
  Verify: timeout works

P539 | Multi-element batch push/pop
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P538
  TryPushBatch(items, count). TryPopBatch(items, max).
  Verify: batch operations

P540 | Cache-line padding for head/tail
  File: include/sync/spsc.hpp (modify)  Dep: P539
  Align head and tail to separate cache lines. Prevents false sharing.
  Verify: different cache lines

P541 | Memory ordering annotations
  File: include/sync/spsc.hpp (modify)  Dep: P540
  memory_order_release on producer, memory_order_acquire on consumer.
  Verify: correct ordering

P542 | Overflow handling strategy
  File: include/sync/spsc.hpp (modify)  Dep: P541
  enum OverflowPolicy { kBlock, kDropOldest, kReturnFalse }.
  Verify: policy respected

P543 | SPSC benchmark
  File: benchmarks/BM_SPSC.cpp (create)  Dep: P542
  Push/pop latency (ns). Throughput vs mutex-based queue. Target: 10x faster.
  Verify: produces numbers

P544 | SPSC with threads test
  File: tests/unit/test_spsc.cpp (create)  Dep: P543
  Producer + consumer threads. All items delivered.
  Verify: ctest -R test_spsc

P545 | Typed SPSC channel (WorkerEvent)
  File: include/sync/spsc.hpp (modify)  Dep: P544
  WorkerEvent { kNewConnection, kConnectionClosed, kMetricsReport, kShutdown }.
  Verify: message type

P546 | Cross-worker connection handoff
  File: include/sync/spsc.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P545
  HandoffConnection(ctx, target_worker). Sends via SPSC.
  Verify: handoff works

P547 | Worker wakeup on message
  File: src/sync/thread_pool.cpp (modify)  Dep: P546
  When message queued, wake target worker via eventfd.
  Verify: worker wakes

P548 | Cross-worker telemetry channel
  File: include/sync/spsc.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P547
  TelemetryMessage { from; stats; }. Periodic stats aggregation.
  Verify: telemetry flows

P549 | SPSC for admin commands
  File: include/sync/spsc.hpp (modify)  Dep: P548
  AdminMessage { cmd; data; }. Admin thread sends config changes.
  Verify: admin commands processed

P550 | Wait-free queue variant
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P549
  WaitFreeQueue. Uses double-buffering for read-only consumers.
  Verify: wait-free read

P551 | Queue statistics
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P550
  QueueStats { capacity, size, pushes, pops, overflows, underflows }.
  Verify: stats accurate

P552 | High contention SPSC test
  File: tests/unit/test_spsc.cpp (modify)  Dep: P551
  10M messages. No lost messages, no corruption.
  Verify: zero loss

P553 | Variable-size messages test
  File: tests/unit/test_spsc.cpp (modify)  Dep: P552
  Messages of various sizes. Verify data integrity.
  Verify: integrity holds

P554 | SPSC queue dump
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P553
  string Dump(). Capacity, fill level, push/pop counts.
  Verify: readable

P555 | SPSC usage docs
  File: include/sync/spsc.hpp (modify)  Dep: P554
  When to use: handoff, telemetry, admin. Not for hot path data.
  Verify: doc renders

P556 | MPSC queue variant
  File: include/sync/spsc.hpp (modify), src/sync/spsc.cpp (modify)  Dep: P555
  template<T> MPSCQueue. Multiple producers, atomic fetch-add for slots.
  Verify: MPSC works

P557 | MCSP stub
  File: include/sync/spsc.hpp (modify)  Dep: P556
  Stub for broadcast/multicast patterns.
  Verify: compiles

P558 | MPSC benchmark
  File: benchmarks/BM_SPSC.cpp (modify)  Dep: P557
  4 producers + 1 consumer. Compare to mutex.
  Verify: MPSC faster

P559 | MPSC 8-producer test
  File: tests/unit/test_spsc.cpp (modify)  Dep: P558
  8 producers, 1 consumer, 1M messages each.
  Verify: all delivered

P560 | Cross-worker communication docs
  File: AGENTS.md (modify)  Dep: P559
  SPSC for 1:1. MPSC for telemetry. No shared state.
  Verify: doc renders
```

### 3.5 Graceful Shutdown & Worker Lifecycle

```
P561 | Drain timeout per worker
  File: src/sync/thread_pool.cpp (modify)  Dep: P479
  Each worker stops accepting, drains connections, stops event loop.
  Verify: drain sequence

P562 | Coordinated shutdown across workers
  File: src/sync/thread_pool.cpp (modify)  Dep: P561
  Main: stop listeners -> signal all workers -> wait for drain -> force close -> join.
  Verify: coordinated shutdown

P563 | Shutdown phases with logging
  File: src/sync/thread_pool.cpp (modify)  Dep: P562
  Phase 1: Stop accepting. Phase 2: Signal workers. Phase 3: Drain. Phase 4: Force close.
  LOG_INFO on each phase.
  Verify: phases logged

P564 | Shutdown progress tracking
  File: include/sync/thread_pool.hpp (modify)  Dep: P563
  ShutdownState { kRunning, kDraining, kForceClosing, kStopped }. ShutdownProgress().
  Verify: state transitions

P565 | Force-close remaining connections
  File: src/sync/thread_pool.cpp (modify)  Dep: P564
  After drain timeout, RST via SO_LINGER {0}.
  Verify: force close

P566 | Active request counting
  File: include/net/connection.hpp (modify)  Dep: P565
  uint32_t active_requests. Increment on start, decrement on end.
  Verify: count accurate

P567 | Connection migration during shutdown
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P566
  If worker shutting down, migrate active connections via SPSC handoff.
  Verify: connections migrated

P568 | Drain progress callback
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P567
  SetDrainCallback(fn). Called with (remaining, total) during drain.
  Verify: callback fires

P569 | Graceful shutdown test
  File: tests/integration/test_graceful_shutdown.cpp (create)  Dep: P568
  Start proxy, long-running requests, SIGTERM. In-flight complete.
  Verify: no connections dropped prematurely

P570 | Shutdown timeout test
  File: tests/integration/test_graceful_shutdown.cpp (modify)  Dep: P569
  Short drain timeout. Force-close after timeout.
  Verify: force close

P571 | Shutdown metrics
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P570
  ShutdownStats { total, drained_count, force_closed_count, drain_duration_ms }.
  Verify: metrics logged

P572 | Health check endpoint
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify),
        src/main.cpp (modify)  Dep: P571
  /health endpoint. Returns 200 when ready, 503 when draining.
  Verify: curl /health returns 200

P573 | Readiness check
  File: include/sync/thread_pool.hpp (modify)  Dep: P572
  bool IsReady(). Workers started, listeners bound, pools warmed.
  Verify: readiness passes at startup

P574 | Liveness check (worker heartbeats)
  File: include/sync/thread_pool.hpp (modify)  Dep: P573
  bool IsAlive(). All worker heartbeats within threshold.
  Verify: liveness check passes

P575 | Health endpoint config
  File: include/core/config.hpp (modify), src/main.cpp (modify)  Dep: P574
  --health-port <port>. Default: disabled.
  Verify: health port works

P576 | Signal handling in multi-worker mode
  File: src/sync/thread_pool.cpp (modify)  Dep: P575
  Main thread handles SIGINT/SIGTERM. Signals workers via SPSC.
  Verify: Ctrl-C shuts down all workers

P577 | SIGHUP reload config stub
  File: src/sync/thread_pool.cpp (modify)  Dep: P576
  Stub for SIGHUP -> reload config.
  Verify: SIGHUP logged

P578 | SIGUSR1/SIGUSR2 stats dump
  File: src/sync/thread_pool.cpp (modify)  Dep: P577
  SIGUSR1 triggers stats dump to stderr. SIGUSR2 profile start/stop.
  Verify: signal triggers action

P579 | PID file cleanup on shutdown
  File: src/main.cpp (modify)  Dep: P578
  Remove PID file during shutdown.
  Verify: PID file removed

P580 | Graceful shutdown architecture docs
  File: AGENTS.md (modify)  Dep: P579
  Shutdown phases, connection drain, force close, health checks.
  Verify: doc renders
```

### 3.6 Multi-Worker Proxy Integration

```
P581 | Multi-worker main()
  File: src/main.cpp (modify)  Dep: P521
  parse config -> create ThreadPool -> workers create listeners -> start -> wait -> shutdown.
  Verify: --workers 4 runs 4 workers

P582 | --listeners config
  File: include/core/config.hpp (modify)  Dep: P581
  --listeners <n>. Number of SO_REUSEPORT listeners.
  Verify: --listeners 1 with --workers 4 works

P583 | Per-worker upstream connection pool
  File: src/sync/thread_pool.cpp (modify)  Dep: P300, P513
  Each worker maintains own upstream connection pool.
  Verify: upstream pools isolated

P584 | Connection binding to worker (client IP hash)
  File: include/sync/thread_pool.hpp (modify)  Dep: P583
  If SO_REUSEPORT unavailable, main accepts, distributes via SPSC by client IP hash.
  Verify: consistent binding

P585 | Consistent hashing for upstream selection
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P301
  Hash request path or client IP to select upstream. Sticky sessions.
  Verify: same path -> same upstream

P586 | Hash ring with virtual nodes
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P585
  ConsistentHashRing { AddNode(name, vnodes=100); SelectNode(key) -> string_view; }.
  Verify: uniform distribution

P587 | Hash ring unit test
  File: tests/unit/test_hash_ring.cpp (create)  Dep: P586
  1000 keys, 3 nodes. Same key -> same node. Add/remove moves minimal keys.
  Verify: ctest -R test_hash_ring

P588 | Hash ring benchmark
  File: benchmarks/BM_HashRing.cpp (create)  Dep: P587
  Lookup latency for 1000 nodes. Target: < 100ns.
  Verify: fast

P589 | Multi-worker integration test
  File: tests/integration/test_multi_worker.cpp (create)  Dep: P588
  4 workers, 1000 requests. Verify all workers serve.
  Verify: distribution across workers

P590 | Connection distribution with SO_REUSEPORT
  File: tests/integration/test_multi_worker.cpp (modify)  Dep: P589
  10000 connections. Count per worker. Roughly uniform.
  Verify: chi-square test passes

P591 | Upstream health checking across workers
  File: tests/integration/test_multi_worker.cpp (modify)  Dep: P590
  One upstream fails. Verify all workers detect and route around.
  Verify: consistent behavior

P592 | Multi-worker throughput benchmark
  File: benchmarks/BM_MultiWorker.cpp (create)  Dep: P591
  Throughput vs worker count. Target: linear scaling.
  Verify: near-linear scaling

P593 | Cross-worker connection handoff test
  File: tests/integration/test_multi_worker.cpp (modify)  Dep: P592
  Connection starts on worker A, handoff to B. Works end-to-end.
  Verify: handoff correct

P594 | Latency breakdown histogram
  File: include/telemetry/latency.hpp (create), src/telemetry/latency.cpp (create)  Dep: P593
  LatencyHistogram { Record(Duration); P50(), P90(), P99(), P99_9() }. Binned log-scale.
  Verify: percentiles accurate

P595 | Per-worker latency tracking
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P594
  Each worker records request latency in own histogram.
  Verify: per-worker histograms

P596 | Aggregate latency across workers
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P595
  MergeLatency() -> LatencyHistogram. Sums all worker histograms.
  Verify: aggregate

P597 | Multi-worker scaling efficiency benchmark
  File: benchmarks/BM_Scaling.cpp (create)  Dep: P596
  Throughput for 1, 2, 4, 8, 16 workers. Plot efficiency.
  Verify: >90% efficiency at 8 workers

P598 | Multi-worker config validation
  File: src/main.cpp (modify)  Dep: P597
  Validate workers <= CPU count. Warn if too many.
  Verify: validation message

P599 | Multi-worker memory isolation test
  File: tests/integration/test_multi_worker.cpp (modify)  Dep: P598
  Check RSS per thread via /proc/self/status. Each has own memory.
  Verify: per-worker isolated

P600 | Multi-worker architecture docs
  File: AGENTS.md (modify)  Dep: P599
  Shared-nothing, SO_REUSEPORT balancing, SPSC handoff, health checks.
  Verify: doc renders
```

### 3.7 Work Stealing & Load Balancing

```
P601 | Idle worker detection
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P531
  IsIdle(). Returns true if worker has < N active connections.
  Verify: idle detected

P602 | Work stealing request structure
  File: include/sync/thread_pool.hpp (modify)  Dep: P601
  struct StealRequest { ConnectionContext* ctx; WorkerId from; }.
  Verify: struct defined

P603 | Steal-from-richest policy
  File: src/sync/thread_pool.cpp (modify)  Dep: P602
  When worker idle, request steal from worker with most connections.
  Verify: steals from richest

P604 | Work item push/pop for migration
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P603
  PushWork(ctx) and PopWork() on per-worker SPSC queue.
  Verify: work items queued

P605 | Migration policy: only steal if imbalance > threshold
  File: src/sync/thread_pool.cpp (modify)  Dep: P604
  Steal only when load(richest) - load(idle) > threshold.
  Verify: no unnecessary steals

P606 | Work stealing unit test
  File: tests/unit/test_work_stealing.cpp (create)  Dep: P605
  Create workers with imbalanced load. Verify steal rebalances.
  Verify: balance achieved

P607 | Work stealing benchmark
  File: benchmarks/BM_WorkStealing.cpp (create)  Dep: P606
  Throughput with and without work stealing. Measure migration cost.
  Verify: benchmark runs

P608 | Load-aware upstream selection
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P607
  Prefer upstream with lowest active connections.
  Verify: load balanced across upstreams

P609 | Weighted round-robin balancing
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P608
  Upstreams have weights. Proportional request distribution.
  Verify: weights respected

P610 | Load balancing docs
  File: AGENTS.md (modify)  Dep: P609
  Work stealing, upstream selection, weighted distribution.
  Verify: doc renders
```

### 3.8 NUMA-Aware Scheduling

```
P611 | Topology-aware initial worker placement
  File: src/sync/thread_pool.cpp (modify)  Dep: P510
  Place first N workers on first NUMA node, rest on second, etc.
  Verify: placement matches NUMA nodes

P612 | Local vs remote memory detection
  File: include/sync/affinity.hpp (modify), src/sync/affinity.cpp (modify)  Dep: P611
  bool IsLocalMemory(const void* addr, int node). Checks if addr on node.
  Verify: detection works

P613 | NUMA migration policy
  File: src/sync/thread_pool.cpp (modify)  Dep: P612
  If worker's memory is on remote node, consider migrating.
  Verify: migration triggered

P614 | NUMA-aware arena allocation
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P613
  Arena::AllocateOnNode(size, node). Uses MPOL_BIND or libnuma.
  Verify: allocates on correct node

P615 | NUMA interleaving for large arenas
  File: include/mem/arena.hpp (modify), src/mem/arena.cpp (modify)  Dep: P614
  For arenas > 1GB, use MPOL_INTERLEAVE across all NUMA nodes.
  Verify: interleaved allocation

P616 | NUMA-aware buffer pools
  File: include/mem/buffer.hpp (modify), src/mem/buffer.cpp (modify)  Dep: P615
  BufferPool allocates from worker's preferred NUMA node.
  Verify: allocates on worker's node

P617 | NUMA topology test
  File: tests/unit/test_numa.cpp (create)  Dep: P616
  Detect NUMA, place worker, verify local allocation.
  Verify: ctest -R test_numa

P618 | Cross-NUMA latency benchmark
  File: benchmarks/BM_Numa.cpp (modify)  Dep: P617
  Measure local vs remote access latency under load.
  Verify: local significantly faster

P619 | NUMA documentation
  File: AGENTS.md (modify)  Dep: P618
  NUMA-aware placement, memory allocation, migration policy.
  Verify: doc renders

P620 | Final NUMA integration review
  File: AGENTS.md (modify)  Dep: P619
  Verify all allocators respect NUMA config.
  Verify: review done
```

### 3.9 Performance Benchmarks & Tuning

```
P621 | Single-thread vs multi-thread throughput benchmark
  File: benchmarks/BM_Scaling.cpp (modify)  Dep: P597
  Compare 1, 2, 4, 8 workers. Linear scaling check.
  Verify: near-linear

P622 | Latency P50/P99 under load benchmark
  File: benchmarks/BM_Proxy.cpp (modify)  Dep: P621
  Measure latency percentiles at 10%, 50%, 90% max throughput.
  Verify: produces numbers

P623 | Perf profiling script
  File: scripts/profile.sh (modify)  Dep: P622
  Run perf record/report on proxy under load. Identify hot spots.
  Verify: perf output generated

P624 | Flamegraph generation script
  File: scripts/profile.sh (modify)  Dep: P623
  Generate Flamegraph from perf output. SVG output.
  Verify: flamegraph.svg created

P625 | Cache miss analysis
  File: scripts/profile.sh (modify)  Dep: P624
  perf stat -e cache-misses,cache-references,LLC-load-misses.
  Verify: cache metrics reported

P626 | Branch misprediction analysis
  File: scripts/profile.sh (modify)  Dep: P625
  perf stat -e branch-misses,branch-instructions.
  Verify: branch metrics

P627 | Syscall count profiling
  File: scripts/profile.sh (modify)  Dep: P626
  perf stat -e syscalls:sys_enter_*, or strace -c.
  Verify: syscall count

P628 | Context switch monitoring
  File: scripts/profile.sh (modify)  Dep: P627
  perf stat -e context-switches.
  Verify: context switch rate

P629 | Optimization pass based on perf data
  File: src/net/event_loop.cpp (modify)  Dep: P628
  Address top 3 hot spots identified by profiling.
  Verify: throughput improves

P630 | Benchmark comparison script
  File: scripts/benchmark.sh (modify)  Dep: P629
  Run all benchmarks, produce comparison table (before/after).
  Verify: comparison output

P631 | Load test with wrk/httperf
  File: scripts/run_load_test.sh (modify)  Dep: P630
  Run wrk or httperf for 30s. Report req/s and latency.
  Verify: load test runs

P632 | Connection scalability test (up to 100k)
  File: scripts/run_load_test.sh (modify)  Dep: P631
  Open 10k, 50k, 100k connections. Measure memory per connection.
  Verify: memory per connection < 4KB

P633 | Steady-state memory test
  File: tests/integration/test_memory_steady.cpp (create)  Dep: P632
  Run proxy for 1 hour under moderate load. Monitor RSS.
  Verify: RSS stable (no leak)

P634 | Benchmark report generation
  File: scripts/benchmark.sh (modify)  Dep: P633
  Generate markdown report of all benchmark results.
  Verify: report.md produced

P635 | Performance tuning documentation
  File: AGENTS.md (modify)  Dep: P634
  Document all tuning knobs: worker count, affinity, buffer sizes, pools.
  Verify: doc renders

P636 | Bottleneck analysis documentation
  File: AGENTS.md (modify)  Dep: P635
  Common bottlenecks and how to diagnose them.
  Verify: doc complete

P637 | Cache-friendly coding guidelines
  File: AGENTS.md (modify)  Dep: P636
  Document cache line alignment, prefetching, hot/cold splitting.
  Verify: doc renders

P638 | Memory bandwidth benchmark
  File: benchmarks/BM_MemoryBandwidth.cpp (create)  Dep: P637
  Measure memory read/write bandwidth. Compare to theoretical max.
  Verify: numbers

P639 | Final performance review
  File: AGENTS.md (modify)  Dep: P638
  Review all performance optimizations applied. Document remaining opportunities.
  Verify: review done

P640 | Performance regression test suite
  File: .github/workflows/benchmark.yml (modify)  Dep: P639
  CI runs benchmarks on every PR. Alert on >5% regression.
  Verify: CI bench step
```

### Folder Tree After Phase 3 (P640)

```
edge-proxy/
├── include/
│   ├── core/         (+ platform.cpp header)
│   ├── net/          (unchanged)
│   ├── http/         (unchanged)
│   ├── mem/          (unchanged)
│   ├── sync/         (unchanged)
│   ├── io/           (unchanged)
│   ├── simd/         (unchanged)
│   └── telemetry/    (+ latency.hpp)
├── src/
│   ├── core/         (unchanged)
│   ├── net/          (unchanged)
│   ├── http/         (unchanged)
│   ├── mem/          (unchanged)
│   ├── sync/         (unchanged)
│   ├── io/           (unchanged)
│   ├── simd/         (unchanged)
│   └── telemetry/    (+ latency.cpp)
├── tests/
│   ├── unit/         (+ test_thread_pool.cpp, test_affinity.cpp, test_spsc.cpp,
│   │                   test_hash_ring.cpp, test_work_stealing.cpp, test_numa.cpp)
│   ├── integration/  (+ test_reuseport.cpp, test_worker_isolation.cpp,
│   │                   test_graceful_shutdown.cpp, test_multi_worker.cpp,
│   │                   test_memory_steady.cpp)
│   └── fuzz/
├── benchmarks/       (+ BM_ThreadPool.cpp, BM_Numa.cpp, BM_Isolation.cpp,
│                       BM_Contention.cpp, BM_SPSC.cpp, BM_HashRing.cpp,
│                       BM_MultiWorker.cpp, BM_Scaling.cpp, BM_WorkStealing.cpp,
│                       BM_MemoryBandwidth.cpp)
├── scripts/          (updated profile.sh, benchmark.sh, run_load_test.sh)
├── cmake/
└── .github/workflows/ (benchmark.yml updated for regression)
```

---


## Phase 4: Modern Linux & Hardware Acceleration
**P641–P790 | 150 programs | Squeeze the last bit of latency using cutting-edge Linux APIs and CPU instructions.**

---

### 4.1 io_uring Migration

```
P641 | IoUring class (io_uring setup)
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P035
  IoUring(entries=1024, flags=0). Wraps io_uring_queue_init().
  Verify: io_uring initialized

P642 | GetSQE() — get next submission entry
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P641
  io_uring_sqe* GetSQE(). Wraps io_uring_get_sqe().
  Verify: SQE obtained

P643 | Submit() — submit SQEs
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P642
  Result<int> Submit(size_t wait_nr=0). Wraps io_uring_submit().
  Verify: submissions succeed

P644 | WaitCQE() — wait for completion
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P643
  Result<int> WaitCQE(io_uring_cqe**). Wraps io_uring_wait_cqe().
  Verify: waits for completion

P645 | PeekCQE() — non-blocking completion check
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P644
  Result<int> PeekCQE(io_uring_cqe**). Wraps io_uring_peek_cqe().
  Verify: non-blocking

P646 | SeenCQE() — mark completion consumed
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P645
  void SeenCQE(io_uring_cqe*). Wraps io_uring_cqe_seen().
  Verify: CQE marked

P647 | SubmitAndWait() — combined submit + wait
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P646
  SubmitAndWait(size_t submit_count). Single syscall.
  Verify: submit + wait

P648 | PrepAccept()
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P647
  PrepAccept(sqe, fd, addr, addrlen, flags). Wraps io_uring_prep_accept().
  Verify: accept via io_uring

P649 | PrepRead()
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P648
  PrepRead(sqe, fd, buf, len, offset). Wraps io_uring_prep_read().
  Verify: read via io_uring

P650 | PrepWrite()
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P649
  PrepWrite(sqe, fd, buf, len, offset). Wraps io_uring_prep_write().
  Verify: write via io_uring

P651 | PrepConnect()
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P650
  PrepConnect(sqe, fd, addr, addrlen). Wraps io_uring_prep_connect().
  Verify: connect via io_uring

P652 | PrepClose()
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P651
  PrepClose(sqe, fd). Wraps io_uring_prep_close().
  Verify: close via io_uring

P653 | io_uring event loop
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P652
  IoUringEventLoop { Run(), Stop() }. Replaces epoll EventLoop.
  Verify: event loop with io_uring

P654 | SetUserData / GetUserData
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P653
  void SetUserData(sqe, void*). void* GetUserData(cqe). For ConnectionContext pointer.
  Verify: round-trip pointer

P655 | Ring buffer statistics
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P654
  RingStats { sqe_used, cqe_used, submissions, completions, overflows }.
  Verify: stats tracked

P656 | Multi-shot accept
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P655
  Accept multiple connections with one SQE. io_uring_prep_multishot_accept.
  Verify: multi-accept works

P657 | Fixed file descriptors
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P656
  Register fd set with io_uring. Use indexed SQE. Reduces atomic ops.
  Verify: fixed fds registered

P658 | Provided buffers
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P657
  Register buffer group. Select buffer ID in SQE. Kernel DMAs directly.
  Verify: provided buffers active

P659 | PrepRecv with provided buffers
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P658
  PrepRecv(sqe, fd, buffer_group_id, len, flags). Uses provided buffers.
  Verify: recv uses provided buffer

P660 | Benchmark io_uring vs epoll
  File: benchmarks/BM_IoUring.cpp (create)  Dep: P659
  Throughput and latency: io_uring vs epoll for read/write/accept.
  Verify: io_uring faster at scale

P661 | IORING_FEAT_FAST_POLL detection
  File: include/io/io_uring.hpp (modify)  Dep: P660
  Check io_uring features on init. Use fast poll if available.
  Verify: features detected

P662 | Kernel version check
  File: include/io/io_uring.hpp (modify)  Dep: P661
  bool IsIoUringSupported(). Check kernel >= 5.1. Fall back to epoll.
  Verify: fallback works

P663 | Hybrid mode (io_uring + epoll)
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P662
  io_uring for read/write. epoll for accept. Best of both.
  Verify: hybrid works

P664 | Submit-and-wait batching
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P663
  Batch SQEs before submit. Multiple I/Os with one syscall.
  Verify: batching reduces syscalls

P665 | Per-op statistics
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P664
  Per-op-type counters: accept, read, write, connect, close.
  Verify: per-op stats

P666 | io_uring unit test
  File: tests/unit/test_io_uring.cpp (create)  Dep: P665
  Accept, read, write, connect via io_uring. Data integrity.
  Verify: ctest -R test_io_uring (if kernel >= 5.1)

P667 | Provided buffers benchmark
  File: benchmarks/BM_IoUring.cpp (modify)  Dep: P666
  Provided buffers throughput vs standard buffers.
  Verify: provided buffers faster

P668 | Zero-copy send via io_uring
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P667
  PrepSendZc(sqe, fd, buf, len, flags). io_uring zero-copy send.
  Verify: zero-copy send

P669 | Nop op for benchmarking
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P668
  PrepNop(sqe). Measures io_uring overhead.
  Verify: nop latency

P670 | Ring resizing
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P669
  Resize(size_t new_entries). Grows/shrinks SQ+CQ.
  Verify: resize works

P671 | IORING_SETUP_COOP_TASKRUN (kernel 5.19+)
  File: include/io/io_uring.hpp (modify)  Dep: P670
  Cooperative task run. Reduces IPIs.
  Verify: flag set

P672 | IORING_SETUP_DEFER_TASKRUN (kernel 6.0+)
  File: include/io/io_uring.hpp (modify)  Dep: P671
  Defer task run to user. Further reduces IPIs.
  Verify: flag set

P673 | Large CQE support (IORING_SETUP_CQE32)
  File: include/io/io_uring.hpp (modify)  Dep: P672
  32-byte CQEs for extra data (e.g., remote address).
  Verify: CQE32 enabled

P674 | io_uring vs epoll at scale benchmark
  File: benchmarks/BM_IoUring.cpp (modify)  Dep: P673
  100k connections, 10k req/s. Compare P50/P99 latency.
  Verify: io_uring wins at scale

P675 | io_uring fallback on old kernels test
  File: tests/unit/test_io_uring.cpp (modify)  Dep: P674
  On kernel < 5.1, graceful fallback to epoll.
  Verify: fallback works

P676 | CQE error handling
  File: src/io/io_uring.cpp (modify)  Dep: P675
  Handle CQE res == -EAGAIN, -ECONNRESET. Map to ErrorCode.
  Verify: errors mapped

P677 | SQE link chain support
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P676
  Link SQEs: read -> write. If first fails, second cancelled.
  Verify: linked ops

P678 | SQE drain support (IOSQE_IO_DRAIN)
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P677
  Drain SQE: waits for previous SQEs before starting. For ordering.
  Verify: drain works

P679 | Syscall avoidance benchmark
  File: benchmarks/BM_IoUring.cpp (modify)  Dep: P678
  Batch submit N ops. Count syscalls. Target: 1 syscall per N ops.
  Verify: batches reduce syscalls

P680 | io_uring architecture docs
  File: AGENTS.md (modify)  Dep: P679
  When to use io_uring vs epoll. Feature detection. Fallback.
  Verify: doc renders
```

### 4.2 SIMD HTTP Parsing

```
P681 | SIMD scan for \r\n\r\n (end of headers)
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P033
  ScanForCRLFCRLF(data, len). AVX2 implementation.
  Verify: finds delimiter

P682 | SSE4.2 fallback for \r\n\r\n scan
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P681
  _mm_cmpistri (SSE4.2) if AVX2 unavailable.
  Verify: SSE4.2 fallback

P683 | Scalar fallback
  File: src/simd/scan.cpp (modify)  Dep: P682
  Naive byte-by-byte scan. For CPUs without SIMD. Runtime dispatch.
  Verify: scalar correct

P684 | SIMD scan for \r\n (end of line)
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P683
  ScanForCRLF(data, len). AVX2.
  Verify: finds \r\n

P685 | SIMD whitespace skip
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P684
  SkipWhitespaceSIMD(data, len). Skips SP, HT.
  Verify: skips whitespace

P686 | SIMD digit detection
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P685
  ScanDigits(data, len). Returns count of consecutive digits.
  Verify: scans digits

P687 | SIMD header name parser
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P686
  ParseHeaderNameSIMD(data, len). Scans for ':' character.
  Verify: header name found

P688 | AVX-512 \r\n\r\n scan
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P687
  _mm512_cmpeq_epi8_mask. 64 bytes per iteration.
  Verify: AVX-512 path

P689 | Runtime CPU dispatch
  File: include/simd/scan.hpp (modify)  Dep: P688
  Function pointers selected at init based on CpuFeatures.
  Verify: correct path selected

P690 | SIMD benchmark vs scalar
  File: benchmarks/BM_SIMD.cpp (create)  Dep: P689
  Throughput GB/s for each scan function. AVX2 vs SSE4.2 vs scalar.
  Verify: AVX2 4x faster

P691 | Integrate SIMD scan with HTTP parser
  File: src/http/parser.cpp (modify)  Dep: P690
  Replace manual \r\n scanning in parser with SIMD scan.
  Verify: parser still passes tests

P692 | SIMD method detection
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P691
  DetectMethodSIMD(data). Compare first bytes against known methods.
  Verify: methods detected

P693 | SIMD version detection
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P692
  ScanHttpVersion(data). Check for "HTTP/".
  Verify: version detected

P694 | SIMD content-length parsing
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P693
  ParseIntSIMD(data, len). AVX2 digit-to-int.
  Verify: "42" -> 42

P695 | SIMD tolower for case-insensitive comparison
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P694
  ToLowerSIMD(data, len). AVX2 vectorized.
  Verify: "Content-Type" -> "content-type"

P696 | Benchmark integrated SIMD parser
  File: benchmarks/BM_SIMD.cpp (modify)  Dep: P695
  Full HTTP request parsing: SIMD-enhanced vs baseline.
  Verify: 30% faster end-to-end

P697 | SIMD edge cases test
  File: tests/unit/test_simd.cpp (create)  Dep: P696
  Short data (< 32 bytes), page boundary, empty data.
  Verify: all handled

P698 | Runtime CPU dispatch test
  File: tests/unit/test_simd.cpp (modify)  Dep: P697
  Verify correct function selected for each CPU feature level.
  Verify: dispatch correct

P699 | SIMD benchmark across paths
  File: benchmarks/BM_SIMD.cpp (modify)  Dep: P698
  Print detected features, test each path.
  Verify: all paths benchmarked

P700 | SIMD architecture docs
  File: include/simd/scan.hpp (modify)  Dep: P699
  Which functions use SIMD, required features, fallback hierarchy.
  Verify: doc renders

P701 | Loop unrolling hints for SIMD
  File: src/simd/scan.cpp (modify)  Dep: P700
  EDGE_UNROLL_LOOP pragma before SIMD loops.
  Verify: performance improvement

P702 | Prefetch hints in scan
  File: src/simd/scan.cpp (modify)  Dep: P701
  __builtin_prefetch(data + 64) in scan loop.
  Verify: improvement

P703 | Misaligned load handling
  File: src/simd/scan.cpp (modify)  Dep: P702
  Use loadu instead of load for non-32-byte aligned data.
  Verify: misaligned works

P704 | Partial load at end of buffer
  File: src/simd/scan.cpp (modify)  Dep: P703
  Mask out bytes beyond buffer length.
  Verify: no OOB read

P705 | SIMD ASan test
  File: tests/unit/test_simd.cpp (modify)  Dep: P704
  Run SIMD tests under AddressSanitizer. No OOB reads.
  Verify: ASan clean

P706 | SIMD URL parser
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P705
  ScanForChar(data, len, char). Find '/' or '?' in URL using SIMD.
  Verify: URL parsed

P707 | SIMD chunked-size parser (hex)
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P706
  ParseHexSIMD(data, len). AVX2 hex-to-int.
  Verify: "1A3" -> 419

P708 | Hex parse benchmark
  File: benchmarks/BM_SIMD.cpp (modify)  Dep: P707
  Hex parse throughput. AVX2 vs scalar.
  Verify: faster

P709 | SIMD header value trim
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P708
  TrimWhitespaceSIMD(data, len). Leading/trailing.
  Verify: whitespace removed

P710 | Full request SIMD benchmark
  File: benchmarks/BM_SIMD.cpp (modify)  Dep: P709
  Complete parse: method + headers + body. All-SIMD vs all-scalar.
  Verify: overall speedup

P711 | AVX-512 VBMI path (vpermb)
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P710
  VPERMB to detect 4-byte pattern in 64 bytes (Ice Lake+).
  Verify: VBMI path

P712 | Compile-time AVX-512 VBMI detection
  File: include/simd/scan.hpp (modify)  Dep: P711
  #ifdef __AVX512VBMI__ for compile-time dispatch.
  Verify: compile-time

P713 | SIMD parser integration docs
  File: AGENTS.md (modify)  Dep: P712
  How SIMD accelerates parser, what to add next.
  Verify: doc renders

P714 | AVX-512 path compile test
  File: tests/unit/test_simd.cpp (modify)  Dep: P713
  If AVX-512 not available in CI, compile-test only.
  Verify: compiles with flags

P715 | SIMD early-exit optimization
  File: src/simd/scan.cpp (modify)  Dep: P714
  If first 32 bytes contain \r\n\r\n, return immediately.
  Verify: fast path for small requests

P716 | Misprediction cost measurement
  File: benchmarks/BM_SIMD.cpp (modify)  Dep: P715
  Measure branch misprediction rate with perf.
  Verify: SIMD reduces branches

P717 | SIMD connection rate limiting
  File: include/simd/scan.hpp (modify), src/simd/scan.cpp (modify)  Dep: P716
  SIMD vectorized IP comparison for blacklist lookup.
  Verify: fast rate limiting

P718 | SIMD load test
  File: tests/integration/test_simd_load.cpp (create)  Dep: P717
  100k req/s through SIMD parser. No crashes.
  Verify: stable under load

P719 | SIMD porting guide docs
  File: AGENTS.md (modify)  Dep: P718
  How to add new SIMD functions: scaffold, dispatch, test.
  Verify: doc renders

P720 | Final SIMD integration review
  File: AGENTS.md (modify)  Dep: P719
  All hot-path scans use SIMD. Document what is not yet SIMD.
  Verify: review done
```

### 4.3 XDP/BPF Kernel Bypass

```
P721 | XdpSocket class
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P035
  XdpSocket. Wraps AF_XDP socket creation.
  Verify: socket created (requires root/CAP_NET_RAW)

P722 | UMEM (User Memory) registration
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P721
  struct XdpUmem { void* area; size_t size; u32 chunk_size; }. Registers memory.
  Verify: UMEM registered

P723 | Fill queue (RX buffers)
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P722
  XdpFillQueue { bool Offer(void* addr); }. Provides RX buffers.
  Verify: fill queue works

P724 | Completion queue (TX done)
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P723
  XdpCompletionQueue { bool Poll(void** addr); }. Reclaims TX buffers.
  Verify: completion queue

P725 | RX ring (incoming packets)
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P724
  XdpRxRing { bool Receive(void** addr, u32* len); }.
  Verify: RX ring works

P726 | TX ring (outgoing packets)
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P725
  XdpTxRing { bool Transmit(void* addr, u32 len); }.
  Verify: TX ring works

P727 | XDP program loading (BPF)
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P726
  LoadXdpProgram(bpf_obj_path, ifindex). Uses bpf() syscall.
  Verify: program loaded

P728 | Pass-through XDP program
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P727
  XDP_PASS all packets. Kernel handles TCP. Userspace gets copy.
  Verify: packets delivered

P729 | XDP redirect mode (XDP_REDIRECT)
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P728
  Redirect TCP packets directly to AF_XDP socket. Bypasses kernel TCP.
  Verify: faster than kernel

P730 | XDP basic flow test
  File: tests/unit/test_xdp.cpp (create)  Dep: P729
  Requires root. Verify packets received via XDP.
  Verify: basic flow

P731 | XDP vs kernel TCP benchmark
  File: benchmarks/BM_XDP.cpp (create)  Dep: P730
  Throughput and latency: XDP vs io_uring vs epoll+TCP.
  Verify: XDP fastest

P732 | BPF HTTP header filter
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P731
  BPF program checks for HTTP/1.1 in first bytes. Routes to XDP socket.
  Verify: HTTP traffic filtered

P733 | XDP statistics
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P732
  XdpStats { rx_packets, tx_packets, dropped, invalid }.
  Verify: stats accurate

P734 | XDP high packet rate test
  File: tests/integration/test_xdp_throughput.cpp (create)  Dep: P733
  1M packets/sec. No drops.
  Verify: high throughput

P735 | AF_XDP multi-queue support
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P734
  One AF_XDP socket per RX queue. Per-queue steering.
  Verify: multi-queue

P736 | XDP with thread-per-core
  File: include/io/xdp.hpp (modify)  Dep: P735
  Each worker owns one AF_XDP socket + one RX queue.
  Verify: per-worker XDP

P737 | XDP fallback when unsupported
  File: tests/integration/test_xdp_fallback.cpp (create)  Dep: P736
  If XDP unavailable, fall back to io_uring or epoll gracefully.
  Verify: graceful fallback

P738 | BPF program hot-reload
  File: include/io/xdp.hpp (modify), src/io/xdp.cpp (modify)  Dep: P737
  Reload BPF program without restarting proxy.
  Verify: hot-reload

P739 | XDP architecture docs
  File: AGENTS.md (modify)  Dep: P738
  When to use XDP vs io_uring vs epoll. Requirements.
  Verify: doc renders

P740 | Final XDP documentation
  File: AGENTS.md (modify)  Dep: P739
  Performance characteristics, setup guide, kernel requirements.
  Verify: doc complete
```

### 4.4 Advanced io_uring Features

```
P741 | IORING_OP_PROVIDE_BUFFERS
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P658
  PrepProvideBuffers(sqe, addr, len, bgid, bid). Register buffer group.
  Verify: buffers provided

P742 | Automatic buffer selection
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P741
  IORING_OP_RECV with IOSQE_BUFFER_SELECT. Kernel picks buffer.
  Verify: auto buffer select

P743 | Multi-shot accept via io_uring
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P742
  io_uring_prep_multishot_accept. Accept many with one SQE.
  Verify: multi-shot accept

P744 | splice via io_uring
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P743
  PrepSplice(sqe, fd_in, off_in, fd_out, off_out, len, flags).
  Verify: splice via io_uring

P745 | io_uring timeout operations
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P744
  PrepTimeout(sqe, duration). Kernel-based timeout via io_uring.
  Verify: timeout fires

P746 | io_uring cancel operations
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P745
  PrepCancel(sqe, user_data). Cancel pending operations.
  Verify: cancel works

P747 | io_uring poll replacement
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P746
  Replace epoll-based wait with io_uring poll. One ring for all I/O.
  Verify: poll replaced

P748 | sqpoll mode (kernel polling thread)
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P747
  IORING_SETUP_SQPOLL. Kernel thread submits SQEs. Zero syscall submission.
  Verify: sqpoll active

P749 | sqpoll thread CPU pinning
  File: include/io/io_uring.hpp (modify), src/io/io_uring.cpp (modify)  Dep: P748
  IORING_REGISTER_SQPOLL. Pin sqpoll thread to worker CPU.
  Verify: sqpoll pinned

P750 | Full io_uring-based proxy benchmark
  File: benchmarks/BM_IoUring.cpp (modify)  Dep: P749
  Full proxy path via io_uring. Compare to epoll baseline.
  Verify: io_uring faster
```

### 4.5 Performance Tuning

```
P751 | Perf profiling of hot paths
  File: scripts/profile.sh (modify)  Dep: P750
  perf record -F 1000 on proxy under load. Generate call graph.
  Verify: perf output

P752 | Flamegraph from perf data
  File: scripts/profile.sh (modify)  Dep: P751
  Generate interactive SVG flamegraph.
  Verify: flamegraph.svg

P753 | Top-down microarchitecture analysis
  File: scripts/profile.sh (modify)  Dep: P752
  perf stat --topdown on proxy under load.
  Verify: topdown metrics

P754 | Optimization: branch reduction
  File: src/http/parser.cpp (modify)  Dep: P753
  Replace branches with lookup tables in hot parse path.
  Verify: fewer branch misses

P755 | Optimization: inlining critical functions
  File: include/http/parser.hpp (modify)  Dep: P754
  EDGE_ALWAYS_INLINE on hot parse functions.
  Verify: performance improves

P756 | Optimization: reduce icache misses
  File: src/net/event_loop.cpp (modify)  Dep: P755
  Reorder functions by hotness. Hot functions adjacent.
  Verify: fewer icache misses

P757 | Optimization: SIMD in hot path
  File: src/http/parser.cpp (modify)  Dep: P756
  Ensure all hot parse loops use SIMD scans.
  Verify: SIMD used

P758 | Optimization: reduce memory bandwidth
  File: src/mem/buffer.cpp (modify)  Dep: P757
  Minimize data movement. Use compact structs.
  Verify: bandwidth reduced

P759 | Performance comparison report
  File: scripts/benchmark.sh (modify)  Dep: P758
  Before/after for each optimization. Table of improvements.
  Verify: report shows gains

P760 | Final performance documentation
  File: AGENTS.md (modify)  Dep: P759
  Complete performance tuning guide. All optimizations applied.
  Verify: doc complete
```

### Folder Tree After Phase 4 (P760)

```
edge-proxy/
├── include/
│   ├── core/         (unchanged)
│   ├── net/          (unchanged)
│   ├── http/         (unchanged)
│   ├── mem/          (unchanged)
│   ├── sync/         (unchanged)
│   ├── io/           (io_uring.hpp, xdp.hpp - updated)
│   ├── simd/         (scan.hpp - updated)
│   └── telemetry/    (unchanged)
├── src/
│   ├── core/         (unchanged)
│   ├── net/          (unchanged)
│   ├── http/         (parser.cpp - SIMD integrated)
│   ├── mem/          (unchanged)
│   ├── sync/         (unchanged)
│   ├── io/           (io_uring.cpp, xdp.cpp - fully implemented)
│   ├── simd/         (scan.cpp - all SIMD functions)
│   └── telemetry/    (unchanged)
├── tests/
│   ├── unit/         (+ test_io_uring.cpp, test_simd.cpp, test_xdp.cpp)
│   ├── integration/  (+ test_simd_load.cpp, test_xdp_throughput.cpp, test_xdp_fallback.cpp)
│   └── fuzz/
├── benchmarks/       (+ BM_IoUring.cpp, BM_SIMD.cpp, BM_XDP.cpp)
├── scripts/          (profile.sh updated with perf commands)
├── cmake/
└── .github/workflows/
```

---


## Phase 5: Observability, Security & Production Polish
**P761–P1000 | 240 programs | Production-ready with TLS, metrics, admin API, rate limiting, HTTP/2, and hardening.**

---

### 5.1 Metrics & Telemetry

```
P761 | MetricsRegistry singleton
  File: include/telemetry/metrics.hpp (modify), src/telemetry/metrics.cpp (modify)  Dep: P035
  MetricsRegistry { Counter(name), Gauge(name), Histogram(name) }. Global registry.
  Verify: counters registered

P762 | Counter metric type
  File: include/telemetry/metrics.hpp (modify), src/telemetry/metrics.cpp (modify)  Dep: P761
  class Counter { Increment(), Add(n), Value() }. Atomic-free per-worker.
  Verify: counter increments

P763 | Gauge metric type
  File: include/telemetry/metrics.hpp (modify), src/telemetry/metrics.cpp (modify)  Dep: P762
  class Gauge { Set(n), Inc(), Dec(), Value() }. For current values.
  Verify: gauge tracks value

P764 | Histogram metric type
  File: include/telemetry/metrics.hpp (modify), src/telemetry/metrics.cpp (modify)  Dep: P763
  class Histogram { Observe(duration), Percentile(p) }. Log-scale bins.
  Verify: percentiles accurate

P765 | Per-worker metrics aggregation
  File: include/telemetry/metrics.hpp (modify), src/telemetry/metrics.cpp (modify)  Dep: P764
  Each worker has local metrics. Global aggregator sums periodically.
  Verify: global metrics accurate

P766 | Connection metrics (total, active, rate)
  File: src/net/event_loop.cpp (modify)  Dep: P765
  Track connections_accepted, connections_active, connections_rate.
  Verify: metrics updated

P767 | Request metrics (total, duration, size)
  File: src/net/event_loop.cpp (modify)  Dep: P766
  Track requests_total, request_duration_seconds, request_bytes.
  Verify: request metrics

P768 | Upstream metrics (total, errors, latency)
  File: src/net/event_loop.cpp (modify)  Dep: P767
  Track upstream_requests_total, upstream_errors, upstream_latency.
  Verify: upstream metrics

P769 | Error metrics by code
  File: src/net/event_loop.cpp (modify)  Dep: P768
  Counter per HTTP status code family (2xx, 3xx, 4xx, 5xx).
  Verify: error metrics

P770 | Memory metrics
  File: src/mem/tracker.cpp (modify)  Dep: P769
  Track memory_used_bytes, memory_rss_bytes, pool_utilization.
  Verify: memory metrics

P771 | Prometheus metrics endpoint
  File: include/telemetry/metrics.hpp (modify), src/telemetry/metrics.cpp (modify)  Dep: P770
  MetricsHandler(ctx). Formats all metrics in Prometheus text format.
  Verify: curl /metrics returns text

P772 | Metrics endpoint integration
  File: src/main.cpp (modify)  Dep: P771
  Register /metrics endpoint on health port.
  Verify: /metrics returns 200

P773 | Metrics endpoint config
  File: include/core/config.hpp (modify)  Dep: P772
  --metrics-port <port>. Enable metrics endpoint.
  Verify: config works

P774 | Metrics cardinality limit
  File: include/telemetry/metrics.hpp (modify), src/telemetry/metrics.cpp (modify)  Dep: P773
  Max metrics limit (10000). LOG_WARN on excessive cardinality.
  Verify: limit enforced

P775 | Metrics unit test
  File: tests/unit/test_metrics.cpp (create)  Dep: P774
  Counter, Gauge, Histogram, aggregation, Prometheus format.
  Verify: ctest -R test_metrics

P776 | Latency histogram per route
  File: include/telemetry/latency.hpp (modify), src/telemetry/latency.cpp (modify)  Dep: P775
  Track latency by request path pattern. Group under load.
  Verify: per-route latencies

P777 | Latency SLO validation
  File: include/telemetry/latency.hpp (modify), src/telemetry/latency.cpp (modify)  Dep: P776
  LatencySLO { max_p99, max_p50 }. Warn if exceeded.
  Verify: SLO warnings

P778 | Event loop metrics
  File: src/net/event_loop.cpp (modify)  Dep: P777
  Track epoll_wait duration, events_per_wait, max_batch.
  Verify: event loop metrics

P779 | Metrics benchmark
  File: benchmarks/BM_Metrics.cpp (create)  Dep: P778
  Counter increment throughput. Target: 100M+ ops/sec.
  Verify: fast

P780 | Metrics documentation
  File: AGENTS.md (modify)  Dep: P779
  All metrics, Prometheus format, cardinality guidance.
  Verify: doc complete

P781 | Structured logging with context IDs
  File: include/core/logger.hpp (modify), src/core/logger.cpp (modify)  Dep: P780
  LOG_INFO("request", "conn_id"_kv=id, "method"_kv=method).
  Verify: logs have context

P782 | Request ID propagation
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P781
  Generate X-Request-Id for each request. Propagate to upstream.
  Verify: request IDs in logs

P783 | Distributed tracing headers
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P782
  Parse/forward traceparent (W3C trace context) headers.
  Verify: trace context propagated

P784 | Span duration tracking
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P783
  Record spans: proxy_total, upstream_connect, upstream_request, response.
  Verify: span durations

P785 | Trace export stub
  File: include/telemetry/metrics.hpp (modify)  Dep: P784
  Stub for OpenTelemetry exporter (future).
  Verify: compiles
```

### 5.2 TLS/SSL Termination

```
P786 | OpenSSL initialization
  File: include/net/tls.hpp (create), src/net/tls.cpp (create)  Dep: P035
  void InitOpenSSL(). OpenSSL_add_all_algorithms, SSL_load_error_strings.
  Verify: OpenSSL initialized

P787 | SSLContext class
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P786
  SSLContext { SSL_CTX* ctx; }. LoadCert(cert_path), LoadKey(key_path).
  Verify: context created

P788 | SSLContext::CreateServer()
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P787
  static Result<SSLContext> CreateServer(cert, key). TLS_server_method.
  Verify: server context ready

P789 | SSLConnection class
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P788
  SSLConnection { SSL* ssl; }. Attach(fd), Handshake(), Read(), Write().
  Verify: SSL connection wraps socket

P790 | Non-blocking SSL handshake
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P789
  AsyncHandshake(). Returns WouldBlock if needs retry.
  Verify: non-blocking handshake

P791 | SSL read with BIO
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P790
  Result<size_t> Read(MutByteSlice). Uses SSL_read.
  Verify: SSL read works

P792 | SSL write with BIO
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P791
  Result<size_t> Write(ConstByteSlice). Uses SSL_write.
  Verify: SSL write works

P793 | TLS config in Config
  File: include/core/config.hpp (modify)  Dep: P792
  --tls-cert, --tls-key, --tls-port. Enable TLS listener.
  Verify: TLS config loaded

P794 | TLS listener creation
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P793
  AddTlsListener(addr, ssl_ctx). Accepts, wraps in SSLConnection.
  Verify: TLS listener works

P795 | TLS handshake in event loop
  File: src/net/event_loop.cpp (modify)  Dep: P794
  On accepted, start TLS handshake. Mark kTlsHandshaking.
  Verify: handshake in event loop

P796 | TLS connection state
  File: include/net/connection.hpp (modify)  Dep: P795
  kTlsHandshaking, kTlsEstablished states. SSL pointer in context.
  Verify: TLS states

P797 | TLS data forwarding
  File: src/net/event_loop.cpp (modify)  Dep: P796
  After handshake, forward as normal. Read/Write through SSL.
  Verify: TLS proxy works

P798 | TLS upstream connection
  File: include/net/event_loop.hpp (modify), src/net/event_loop.cpp (modify)  Dep: P797
  ConnectToUpstreamTls(ctx, addr, ssl_ctx). TLS to upstream.
  Verify: upstream TLS works

P799 | ALPN negotiation
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P798
  SetAlpnProtocols(["h2", "http/1.1"]). Server ALPN.
  Verify: ALPN set

P800 | TLS session caching
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P799
  Enable session cache. SSL_CTX_set_session_cache_mode.
  Verify: sessions cached

P801 | TLS config validation
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P800
  Validate cert and key files exist. Check permissions.
  Verify: validation works

P802 | TLS certificate reload (SIGHUP)
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P801
  ReloadCert(). Replace SSL_CTX. New connections use new cert.
  Verify: cert reloaded

P803 | TLS unit test
  File: tests/unit/test_tls.cpp (create)  Dep: P802
  Self-signed cert, connect, handshake, send data.
  Verify: ctest -R test_tls

P804 | TLS integration test
  File: tests/integration/test_tls_proxy.cpp (create)  Dep: P803
  Proxy with TLS listener, plain upstream. Verify end-to-end.
  Verify: TLS e2e passes

P805 | TLS benchmark
  File: benchmarks/BM_TLS.cpp (create)  Dep: P804
  Handshake rate, throughput with TLS. Compare to non-TLS.
  Verify: numbers

P806 | TLS mutual auth stub
  File: include/net/tls.hpp (modify)  Dep: P805
  Stub for mTLS (client cert verification).
  Verify: compiles

P807 | TLS protocol version config
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P806
  --tls-min-version {TLSv1.2, TLSv1.3}. Default TLSv1.2.
  Verify: version enforced

P808 | TLS cipher suite config
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P807
  --tls-ciphers. Set SSL_CTX_set_cipher_list.
  Verify: ciphers restricted

P809 | TLS documentation
  File: AGENTS.md (modify)  Dep: P808
  TLS setup, cert generation, performance notes.
  Verify: doc renders

P810 | TLS final review
  File: AGENTS.md (modify)  Dep: P809
  Review security: no weak ciphers, no ancient protocols.
  Verify: review done
```

### 5.3 Admin API & Config Reload

```
P811 | AdminServer class
  File: include/net/admin.hpp (create), src/net/admin.cpp (create)  Dep: P811
  AdminServer(EventLoop*, Config*). HTTP server on admin port.
  Verify: admin server starts

P812 | Admin route registration
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P811
  void Handle(route, callback). Registers admin endpoint.
  Verify: routes registered

P813 | /stats endpoint
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P812
  Returns JSON with all stats: connections, requests, memory, uptime.
  Verify: curl /stats returns JSON

P814 | /health endpoint
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P813
  Returns 200 with health status. Draining, degraded, OK.
  Verify: curl /health returns 200

P815 | /config endpoint
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P814
  Returns current config as JSON. Masks secrets.
  Verify: curl /config returns config

P816 | /config/reload endpoint
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P815
  POST /config/reload. Triggers SIGHUP-like reload.
  Verify: config reloads

P817 | /logging endpoint
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P816
  GET /logging returns current level. POST /logging sets level.
  Verify: log level changes

P818 | /connections endpoint
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P817
  Lists active connections: ID, client, state, duration.
  Verify: connections listed

P819 | /connections/:id/close endpoint
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P818
  POST /connections/42/close. Force-close a connection.
  Verify: connection closed

P820 | /metrics endpoint (Prometheus)
  File: include/net/admin.hpp (modify), src/net/admin.cpp (modify)  Dep: P819
  Prometheus text format on admin port.
  Verify: /metrics on admin port

P821 | Admin authentication stub
  File: include/net/admin.hpp (modify)  Dep: P820
  Stub for admin auth (token-based).
  Verify: compiles

P822 | Admin rate limiting
  File: src/net/admin.cpp (modify)  Dep: P821
  Rate limit admin endpoint: 10 req/s per IP.
  Verify: rate limited

P823 | Admin config
  File: include/core/config.hpp (modify)  Dep: P822
  --admin-port <port>. Default: 8081. --admin-auth-token.
  Verify: admin config

P824 | Admin integration test
  File: tests/integration/test_admin.cpp (create)  Dep: P823
  Start proxy, call /stats, /health, /config, verify.
  Verify: ctest -R test_admin

P825 | Config reload test
  File: tests/integration/test_admin.cpp (modify)  Dep: P824
  POST /config/reload. Change config, verify new config active.
  Verify: reload works

P826 | SIGHUP config reload handler
  File: src/main.cpp (modify)  Dep: P825
  Handle SIGHUP: reload config file, apply changes.
  Verify: kill -HUP reloads

P827 | Connection drain on config change
  File: src/net/admin.cpp (modify)  Dep: P826
  On config reload, drain old connections before fully switching.
  Verify: graceful transition

P828 | Config change validation
  File: include/core/config.hpp (modify), src/core/config.cpp (modify)  Dep: P827
  Validate new config before applying. Rollback on failure.
  Verify: invalid config rejected

P829 | Admin API documentation
  File: AGENTS.md (modify)  Dep: P828
  All admin endpoints, examples, authentication.
  Verify: doc renders

P830 | Admin API benchmark
  File: benchmarks/BM_Admin.cpp (create)  Dep: P829
  Admin endpoint throughput. Should be lightweight.
  Verify: numbers
```

### 5.4 Rate Limiting & Security

```
P831 | TokenBucket rate limiter
  File: include/net/ratelimit.hpp (create), src/net/ratelimit.cpp (create)  Dep: P035
  TokenBucket { rate, burst }. Allow(), Consume().
  Verify: allows up to burst, then throttles

P832 | Per-IP rate limiter
  File: include/net/ratelimit.hpp (modify), src/net/ratelimit.cpp (modify)  Dep: P831
  IpRateLimiter { flat_hash_map<uint32_t, TokenBucket> }. Limit(ip).
  Verify: per-IP limits

P833 | Connection rate limiting
  File: src/net/event_loop.cpp (modify)  Dep: P832
  On accept, check IP rate limit. 503 if exceeded.
  Verify: connects rate limited

P834 | Request rate limiting
  File: src/net/event_loop.cpp (modify)  Dep: P833
  Per-IP request rate limit. 429 Too Many Requests.
  Verify: request rate limited

P835 | Concurrent connection limit per IP
  File: include/net/ratelimit.hpp (modify), src/net/ratelimit.cpp (modify)  Dep: P834
  Max concurrent connections per IP. Default: 100.
  Verify: limit enforced

P836 | Rate limit config
  File: include/core/config.hpp (modify)  Dep: P835
  --rate-limit-rps, --rate-limit-burst, --max-conns-per-ip.
  Verify: config respected

P837 | Rate limit headers
  File: include/net/ratelimit.hpp (modify), src/net/ratelimit.cpp (modify)  Dep: P836
  X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset.
  Verify: headers sent

P838 | Request body size limit
  File: include/net/ratelimit.hpp (modify), src/net/ratelimit.cpp (modify)  Dep: P837
  --max-body-size. Return 413 if exceeded.
  Verify: large body rejected

P839 | Header size limit
  File: include/http/parser.hpp (modify)  Dep: P838
  ParserConfig::max_header_size. Return 431 if exceeded.
  Verify: large header rejected

P840 | URL length limit
  File: include/http/parser.hpp (modify)  Dep: P839
  ParserConfig::max_url_length. Default: 8KB.
  Verify: long URL rejected

P841 | Connection timeout limits
  File: include/core/config.hpp (modify)  Dep: P840
  --idle-timeout, --request-timeout, --connect-timeout.
  Verify: timeouts enforced

P842 | Slowloris protection
  File: src/net/event_loop.cpp (modify)  Dep: P841
  Minimum data rate. If below threshold, close connection.
  Verify: slow client closed

P843 | IP blacklist/whitelist
  File: include/net/ratelimit.hpp (modify), src/net/ratelimit.cpp (modify)  Dep: P842
  --blacklist-ip, --whitelist-ip. Accept or reject lists.
  Verify: IP list works

P844 | Security headers
  File: src/net/event_loop.cpp (modify)  Dep: P843
  Add X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security.
  Verify: security headers present

P845 | Rate limit unit test
  File: tests/unit/test_ratelimit.cpp (create)  Dep: P844
  TokenBucket, per-IP, concurrent limit.
  Verify: ctest -R test_ratelimit

P846 | Rate limit integration test
  File: tests/integration/test_ratelimit.cpp (create)  Dep: P845
  Exceed rate limit, verify 429. Wait, verify allowed.
  Verify: rate limit e2e

P847 | DOS protection test
  File: tests/integration/test_dos_protection.cpp (create)  Dep: P846
  Rapid connections from single IP. Verify throttled.
  Verify: DOS protection works

P848 | Security documentation
  File: AGENTS.md (modify)  Dep: P847
  Rate limiting, DOS protection, security headers, limits.
  Verify: doc renders

P849 | Security audit
  File: AGENTS.md (modify)  Dep: P848
  Audit: input validation, memory safety, error handling.
  Verify: audit done

P850 | Final security review
  File: AGENTS.md (modify)  Dep: P849
  Review all security features. Document remaining concerns.
  Verify: review done
```

### 5.5 HTTP/2 Support

```
P851 | HTTP/2 connection preface detection
  File: include/http/parser.hpp (modify), src/http/parser.cpp (modify)  Dep: P859
  Detect h2c upgrade or PRI * HTTP/2.0 preface.
  Verify: h2 preface detected

P852 | HTTP/2 frame header struct
  File: include/http/h2/frame.hpp (create)  Dep: P851
  struct H2Frame { length, type, flags, stream_id, payload }. 9-byte header.
  Verify: sizeof == 9

P853 | H2 frame type enum
  File: include/http/h2/frame.hpp (modify)  Dep: P852
  enum H2FrameType { DATA, HEADERS, PRIORITY, RST_STREAM, SETTINGS, PUSH_PROMISE, PING, GOAWAY, WINDOW_UPDATE, CONTINUATION }.
  Verify: all types

P854 | H2Settings struct
  File: include/http/h2/settings.hpp (create)  Dep: P853
  struct H2Settings { header_table_size, enable_push, max_concurrent_streams, initial_window_size, max_frame_size, max_header_list_size }.
  Verify: defaults per RFC

P855 | H2 connection state machine
  File: include/http/h2/connection.hpp (create), src/http/h2/connection.cpp (create)  Dep: P854
  enum H2ConnState { kPreface, kSettingsSent, kSettingsAck, kActive, kGoaway, kClosed }.
  Verify: state transitions

P856 | H2 stream state machine
  File: include/http/h2/stream.hpp (create)  Dep: P855
  enum H2StreamState { kIdle, kOpen, kHalfClosedRemote, kHalfClosedLocal, kClosed }.
  Verify: RFC 7540 states

P857 | H2 frame read/write
  File: include/http/h2/frame.hpp (modify), src/http/h2/frame.cpp (create)  Dep: P856
  ReadFrame(ConstByteSlice) -> Result<H2Frame>. WriteFrame(BufferChain&, H2Frame).
  Verify: frame round-trip

P858 | H2 settings handling
  File: include/http/h2/settings.hpp (modify), src/http/h2/settings.cpp (create)  Dep: P857
  HandleSettings(H2Settings). Apply settings, send ACK.
  Verify: settings exchanged

P859 | H2 header compression (HPACK) stub
  File: include/http/h2/hpack.hpp (create)  Dep: P858
  struct HpackTable { Encode(headers), Decode(data) }. Dynamic table.
  Verify: stub compiles

P860 | H2 DATA frame handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P859
  On DATA frame, forward payload to stream. Handle flow control.
  Verify: DATA frames forwarded

P861 | H2 HEADERS frame handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P860
  On HEADERS frame, decode HPACK, create proxy request.
  Verify: HEADERS processed

P862 | H2 stream multiplexing
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P861
  Multiple streams on one connection. Interleaved frames.
  Verify: multiplexed streams

P863 | H2 flow control
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P862
  WINDOW_UPDATE handling. Per-stream and connection-level windows.
  Verify: flow control works

P864 | H2 GOAWAY handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P863
  Graceful shutdown: send GOAWAY with last_stream_id.
  Verify: GOAWAY handled

P865 | H2 PING handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P864
  Respond to PING with PING ACK. Track RTT.
  Verify: PING/PONG

P866 | H2 RST_STREAM handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P865
  On RST_STREAM, cancel proxy request. Clean up.
  Verify: stream reset

P867 | H2 PRIORITY handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P866
  Track stream priority tree. Use for scheduling.
  Verify: priority tracked

P868 | H2 CONTINUATION handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P867
  Reassemble HEADERS split across CONTINUATION frames.
  Verify: continuation assembled

P869 | H2 to HTTP/1.1 translation
  File: include/http/h2/proxy.hpp (create), src/http/h2/proxy.cpp (create)  Dep: P868
  Convert h2 request to h1 for upstream. Convert h1 response to h2.
  Verify: h2 -> h1 -> h2 round-trip

P870 | H2 connection management
  File: include/http/h2/h2_connection.hpp (modify), src/http/h2/h2_connection.cpp (modify)  Dep: P869
  H2 connection per client. Manages stream pool.
  Verify: h2 connections managed

P871 | H2 settings config
  File: include/core/config.hpp (modify)  Dep: P870
  --h2-max-concurrent-streams, --h2-initial-window-size.
  Verify: h2 config

P872 | H2 ALPN negotiation (via TLS)
  File: include/net/tls.hpp (modify), src/net/tls.cpp (modify)  Dep: P871
  On ALPN with h2, upgrade connection to H2.
  Verify: h2 via ALPN

P873 | H2 cleartext upgrade (h2c)
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P872
  Handle HTTP/1.1 Upgrade: h2c. Or direct PRI preface.
  Verify: h2c upgrade

P874 | H2 integration test
  File: tests/integration/test_h2.cpp (create)  Dep: P873
  Send h2 preface, SETTINGS, HEADERS, DATA. Verify proxy forwards.
  Verify: h2 e2e

P875 | H2 benchmark
  File: benchmarks/BM_H2.cpp (create)  Dep: P874
  Multiple streams throughput. Compare to h1 pipeline.
  Verify: h2 faster for multiplex

P876 | H2 HPACK dynamic table
  File: include/http/h2/hpack.hpp (modify), src/http/h2/hpack.cpp (create)  Dep: P875
  Full HPACK encoder/decoder with dynamic table.
  Verify: HPACK round-trip

P877 | H2 push promise stub
  File: include/http/h2/connection.hpp (modify)  Dep: P876
  Stub for server push. Not enabled by default.
  Verify: compiles

P878 | H2 error handling
  File: include/http/h2/connection.hpp (modify), src/http/h2/connection.cpp (modify)  Dep: P877
  H2 error codes. PROTOCOL_ERROR, FLOW_CONTROL_ERROR, etc.
  Verify: errors produce GOAWAY

P879 | H2 documentation
  File: AGENTS.md (modify)  Dep: P878
  HTTP/2 support, limitations, performance characteristics.
  Verify: doc renders

P880 | H2 final review
  File: AGENTS.md (modify)  Dep: P879
  Review h2 implementation completeness. Document gaps.
  Verify: review done
```

### 5.6 Final Production Hardening

```
P881 | Graceful degradation on resource exhaustion
  File: src/net/event_loop.cpp (modify)  Dep: P880
  On OOM or fd exhaustion, close oldest idle connection.
  Verify: degrades gracefully

P882 | Connection memory limit
  File: include/net/connection.hpp (modify), src/net/connection.cpp (modify)  Dep: P881
  --max-connection-memory. Close connections when exceeded.
  Verify: limit enforced

P883 | Cgroup memory limit awareness
  File: include/core/platform.hpp (modify), src/core/platform.cpp (modify)  Dep: P882
  uint64_t GetCgroupMemoryLimit(). Reads /sys/fs/cgroup/memory.max.
  Verify: reports limit

P884 | oom_score_adj configuration
  File: src/main.cpp (modify)  Dep: P883
  Set oom_score_adj to -500 to protect proxy from OOM killer.
  Verify: oom score set

P885 | File descriptor limits
  File: src/main.cpp (modify)  Dep: P884
  Setrlimit(RLIMIT_NOFILE, max). Ensure fd limit sufficient.
  Verify: fd limit raised

P886 | Capability dropping
  File: src/main.cpp (modify)  Dep: P885
  After binding privileged ports, drop capabilities via capset.
  Verify: capabilities dropped

P887 | Seccomp BPF filter
  File: include/core/seccomp.hpp (create), src/core/seccomp.cpp (create)  Dep: P886
  Install seccomp filter. Allow only needed syscalls.
  Verify: seccomp active

P888 | Seccomp allowlist definition
  File: include/core/seccomp.hpp (modify)  Dep: P887
  Allowlist: read, write, accept, connect, epoll_wait, etc. Block unused.
  Verify: blocked syscall kills process

P889 | Seccomp unit test
  File: tests/unit/test_seccomp.cpp (create)  Dep: P888
  Install filter, verify allowed syscall works, blocked fails.
  Verify: seccomp test

P890 | Daemonize with systemd notify
  File: src/main.cpp (modify)  Dep: P889
  sd_notify(READY=1). Watchdog support.
  Verify: systemd integration

P891 | Core dump configuration
  File: src/main.cpp (modify)  Dep: P890
  Set RLIMIT_CORE. Configure /proc/sys/kernel/core_pattern.
  Verify: core dumps enabled

P892 | Signal handling robustness
  File: src/main.cpp (modify)  Dep: P891
  Block all signals in worker threads. Handle only in main.
  Verify: signal handling safe

P893 | Stack size configuration
  File: src/main.cpp (modify)  Dep: P892
  pthread_attr_setstacksize for worker threads. Default: 2MB.
  Verify: stack size set

P894 | Watchdog timer
  File: include/sync/thread_pool.hpp (modify), src/sync/thread_pool.cpp (modify)  Dep: P893
  Main thread watchdog. If no worker heartbeat for 10s, abort.
  Verify: watchdog triggers

P895 | Startup health check
  File: src/main.cpp (modify)  Dep: P894
  Wait for workers to be ready before accepting. Retry loop.
  Verify: startup health

P896 | Graceful shutdown on SIGTERM
  File: src/main.cpp (modify)  Dep: P895
  Already implemented. Finalize: log all phases.
  Verify: graceful shutdown logged

P897 | Configuration validation at startup
  File: src/main.cpp (modify)  Dep: P896
  Full config validation before starting workers.
  Verify: invalid config exits cleanly

P898 | Configuration dump at startup
  File: src/main.cpp (modify)  Dep: P897
  Log effective config at startup. Mask secrets.
  Verify: config logged

P899 | Version logging at startup
  File: src/main.cpp (modify)  Dep: P898
  Log version, git commit, build type, compiler.
  Verify: version logged

P900 | Startup banner
  File: src/main.cpp (modify)  Dep: P899
  ASCII art banner with version info.
  Verify: banner displayed

P901 | Comprehensive logging at startup
  File: src/main.cpp (modify)  Dep: P900
  Log: workers, listen addrs, upstreams, memory limits, features.
  Verify: startup logs complete

P902 | Dockerfile optimization
  File: Dockerfile (modify)  Dep: P901
  Multi-stage build. Minimal runtime image. Distroless base.
  Verify: image size < 20MB

P903 | Docker healthcheck
  File: Dockerfile (modify)  Dep: P902
  HEALTHCHECK --interval=5s curl --fail http://localhost/health.
  Verify: docker ps shows healthy

P904 | Docker compose for testing
  File: docker-compose.yml (create)  Dep: P903
  Proxy + upstream echo server. One command to test.
  Verify: docker compose up works

P905 | Kubernetes deployment manifests
  File: deploy/k8s/deployment.yaml, service.yaml, configmap.yaml (create)  Dep: P904
  Basic k8s deployment with health checks, resource limits.
  Verify: kubectl apply works

P906 | ConfigMap for proxy config
  File: deploy/k8s/configmap.yaml (modify)  Dep: P905
  Proxy config as ConfigMap. Mount as file.
  Verify: config loaded from ConfigMap

P907 | Resource limits in k8s
  File: deploy/k8s/deployment.yaml (modify)  Dep: P906
  CPU and memory limits. Request/limit pattern.
  Verify: limits set

P908 | PodDisruptionBudget
  File: deploy/k8s/pdb.yaml (create)  Dep: P907
  minAvailable: 1. Prevent all replicas down during updates.
  Verify: PDB created

P909 | Horizontal Pod Autoscaler
  File: deploy/k8s/hpa.yaml (create)  Dep: P908
  CPU-based autoscaling. Min 2, max 10 replicas.
  Verify: HPA created

P910 | Prometheus ServiceMonitor
  File: deploy/k8s/servicemonitor.yaml (create)  Dep: P909
  Scrape config for Prometheus operator.
  Verify: ServiceMonitor created

P911 | Grafana dashboard
  File: deploy/grafana/dashboard.json (create)  Dep: P910
  Dashboard: requests, latency, errors, connections, memory.
  Verify: dashboard importable

P912 | Alerts configuration
  File: deploy/prometheus/alerts.yaml (create)  Dep: P911
  Alerts: high latency, error rate spike, connection limit.
  Verify: alerts valid

P913 | Fuzz testing integration
  File: tests/fuzz/CMakeLists.txt (modify)  Dep: P912
  Build fuzz targets in CI. Run for 1 min each.
  Verify: fuzz CI step

P914 | Fuzz test: HTTP parser
  File: tests/fuzz/fuzz_parser.cpp (modify)  Dep: P913
  Extend fuzz coverage: chunked, trailers, edge cases.
  Verify: 1M iterations no crash

P915 | Fuzz test: config parser
  File: tests/fuzz/fuzz_config.cpp (create)  Dep: P914
  Fuzz config file parsing. No crashes.
  Verify: config fuzz runs

P916 | Fuzz test: address parser
  File: tests/fuzz/fuzz_address.cpp (create)  Dep: P915
  Fuzz address parsing. No crashes.
  Verify: address fuzz runs

P917 | Fuzz with ASan
  File: .github/workflows/ci.yml (modify)  Dep: P916
  Run fuzz tests with AddressSanitizer in CI.
  Verify: CI fuzz step

P918 | Integration test with chaos
  File: tests/integration/test_chaos.cpp (create)  Dep: P917
  Random connection drops, slow writes, partial reads.
  Verify: proxy handles chaos

P919 | Long-running stability test
  File: tests/integration/test_stability.cpp (create)  Dep: P918
  24h test with continuous load. Monitor memory and latency.
  Verify: stable for 24h

P920 | Performance regression benchmark
  File: .github/workflows/benchmark.yml (modify)  Dep: P919
  Compare benchmark results against baseline. Fail on regression.
  Verify: CI benchmark comparison

P921 | Memory leak detection in CI
  File: .github/workflows/ci.yml (modify)  Dep: P920
  Run valgrind on unit tests. Fail on leaks.
  Verify: CI valgrind step

P922 | Thread sanitizer in CI
  File: .github/workflows/ci.yml (modify)  Dep: P921
  Run unit tests with ThreadSanitizer. Detect races.
  Verify: CI TSan step

P923 | Undefined behavior sanitizer
  File: .github/workflows/ci.yml (modify)  Dep: P922
  Run with UBSan. Detect UB.
  Verify: CI UBSan step

P924 | Code coverage reporting
  File: .github/workflows/ci.yml (modify)  Dep: P923
  Generate coverage report. Upload to Codecov.
  Verify: coverage reported

P925 | Static analysis in CI
  File: .github/workflows/ci.yml (modify)  Dep: P924
  Run clang-tidy checks on all code.
  Verify: CI static analysis

P926 | SonarCloud integration
  File: .github/workflows/ci.yml (modify)  Dep: P925
  SonarCloud scan for code quality and security.
  Verify: SonarCloud report

P927 | Documentation site stub
  File: docs/index.md (create)  Dep: P926
  MkDocs or Docusaurus site. Build in CI.
  Verify: docs site builds

P928 | API reference docs
  File: docs/api.md (create)  Dep: P927
  Auto-generated from Doxygen comments.
  Verify: API docs generated

P929 | Configuration reference docs
  File: docs/configuration.md (create)  Dep: P928
  All config keys, defaults, examples.
  Verify: config docs complete

P930 | Performance tuning docs
  File: docs/performance.md (create)  Dep: P929
  Tuning guide: worker count, buffer sizes, affinity.
  Verify: perf docs complete

P931 | Deployment guide
  File: docs/deployment.md (create)  Dep: P930
  Docker, k8s, systemd, configuration.
  Verify: deployment docs complete

P932 | Security guide
  File: docs/security.md (create)  Dep: P931
  TLS, rate limiting, seccomp, capability dropping.
  Verify: security docs complete

P933 | README update
  File: README.md (modify)  Dep: P932
  Features, quick start, benchmarks, badges.
  Verify: README renders

P934 | CONTRIBUTING guide
  File: CONTRIBUTING.md (create)  Dep: P933
  How to contribute, code style, PR process.
  Verify: CONTRIBUTING renders

P935 | CODE_OF_CONDUCT
  File: CODE_OF_CONDUCT.md (create)  Dep: P934
  Standard code of conduct.
  Verify: file created

P936 | License file
  File: LICENSE (create)  Dep: P935
  Apache 2.0 or MIT license.
  Verify: license file

P937 | RELEASE_NOTES template
  File: RELEASE_NOTES.md (create)  Dep: P936
  Template for release notes.
  Verify: template renders

P938 | Pre-commit hooks
  File: .pre-commit-config.yaml (create)  Dep: P937
  clang-format, trailing whitespace, EOF newline.
  Verify: pre-commit runs

P939 | Git blame ignore file
  File: .git-blame-ignore-revs (create)  Dep: P938
  Ignore formatting commits in git blame.
  Verify: file created

P940 | Final documentation review
  File: AGENTS.md (modify)  Dep: P939
  Complete project documentation review.
  Verify: docs complete

P941 | Final code review pass
  File: (all files)  Dep: P940
  Review all code for: style, safety, performance, correctness.
  Verify: review complete

P942 | Final security review
  File: AGENTS.md (modify)  Dep: P941
  Security audit of entire codebase.
  Verify: security review complete

P943 | Performance optimization final pass
  File: (hot files)  Dep: P942
  Final optimization pass on identified hot spots.
  Verify: benchmarks at target

P944 | API stability review
  File: (header files)  Dep: P943
  Review public API for consistency and stability.
  Verify: API stable

P945 | Error message review
  File: (all files)  Dep: P944
  Review all error messages for clarity and consistency.
  Verify: errors clear

P946 | Log message review
  File: (all files)  Dep: P945
  Review log levels: info vs debug vs trace appropriateness.
  Verify: logs appropriate

P947 | Comment review
  File: (all files)  Dep: P946
  Review and cleanup comments. Remove stale ones.
  Verify: comments accurate

P948 | Dead code removal
  File: (all files)  Dep: P947
  Remove unused code, variables, functions.
  Verify: no dead code

P949 | Dependency review
  File: CMakeLists.txt (modify)  Dep: P948
  Audit dependencies. Remove unused. Update versions.
  Verify: minimal dependencies

P950 | Final build optimization
  File: CMakeLists.txt (modify)  Dep: P949
  -Oz for size, strip symbols, LTO, debug info in separate package.
  Verify: binary size < 5MB

P951 | CPack packaging
  File: CMakeLists.txt (modify)  Dep: P950
  CPack for .deb, .rpm, .tar.gz. Install rules.
  Verify: package builds

P952 | RPM spec file
  File: packaging/edge-proxy.spec (create)  Dep: P951
  RPM spec for Fedora/RHEL.
  Verify: rpmbuild works

P953 | Debian control file
  File: packaging/debian/control (create)  Dep: P952
  Debian packaging metadata.
  Verify: dpkg-buildpackage works

P954 | Homebrew formula stub
  File: packaging/homebrew.rb (create)  Dep: P953
  Homebrew formula for macOS.
  Verify: stub created

P955 | Nix package stub
  File: packaging/default.nix (create)  Dep: P954
  Nix derivation for edge-proxy.
  Verify: stub created

P956 | Continuous delivery pipeline
  File: .github/workflows/release.yml (create)  Dep: P955
  On tag: build, test, package, publish GitHub release.
  Verify: CD pipeline works

P957 | Docker image publish
  File: .github/workflows/docker.yml (create)  Dep: P956
  Build and publish Docker image to GHCR.
  Verify: image published

P958 | Version bump script
  File: scripts/bump_version.sh (create)  Dep: P957
  Script to bump version in CMakeLists.txt and create tag.
  Verify: script works

P959 | Changelog generation
  File: scripts/generate_changelog.sh (create)  Dep: P958
  Generate CHANGELOG.md from git history.
  Verify: changelog generated

P960 | Release checklist
  File: RELEASE_CHECKLIST.md (create)  Dep: P959
  Release process checklist.
  Verify: checklist renders

P961 | Benchmark baseline capture
  File: scripts/capture_baseline.sh (create)  Dep: P960
  Run benchmarks, save baseline numbers.
  Verify: baseline captured

P962 | Load test suite
  File: tests/load/run.sh (create)  Dep: P961
  wrk/httperf based load tests. Multiple scenarios.
  Verify: load tests run

P963 | Latency profile under load
  File: scripts/latency_profile.sh (create)  Dep: P962
  Measure latency distribution at various throughput levels.
  Verify: latency profile

P964 | Connection scalability profile
  File: scripts/conn_scalability.sh (create)  Dep: P963
  Measure memory per connection at scale (10k, 50k, 100k).
  Verify: scalability profile

P965 | Throughput vs latency curve
  File: scripts/throughput_latency.sh (create)  Dep: P964
  Generate throughput vs latency curve. Find saturation point.
  Verify: curve generated

P966 | Performance report generation
  File: scripts/generate_perf_report.sh (create)  Dep: P965
  Generate comprehensive performance report.
  Verify: report generated

P967 | Final project review
  File: AGENTS.md (modify)  Dep: P966
  Complete project review. All 1000 programs done.
  Verify: file complete

P968 | Project summary document
  File: SUMMARY.md (create)  Dep: P967
  Architecture overview, key features, performance numbers.
  Verify: summary renders

P969 | Public announcement draft
  File: ANNOUNCEMENT.md (create)  Dep: P968
  Draft for public release announcement.
  Verify: announcement written

P970 | Logo and branding
  File: logo.svg (create)  Dep: P969
  Simple project logo.
  Verify: logo renders

P971 | Badges for README
  File: README.md (modify)  Dep: P970
  CI status, coverage, license, version badges.
  Verify: badges render

P972 | Final README polish
  File: README.md (modify)  Dep: P971
  Polish README: features, quick start, benchmarks, links.
  Verify: README complete

P973 | Final AGENTS.md update
  File: AGENTS.md (modify)  Dep: P972
  Complete dev conventions: build, test, style, commit.
  Verify: AGENTS.md complete

P974 | Remove all TODO/FIXME comments
  File: (all files)  Dep: P973
  Resolve or remove all TODO/FIXME/HACK comments.
  Verify: no TODOs remain

P975 | Final commit and tag
  File: (none)  Dep: P974
  git commit -m "edge-proxy v1.0.0" and tag.
  Verify: git tag v1.0.0

P976 | Release v1.0.0
  File: (none)  Dep: P975
  Publish release: GitHub, Docker Hub, packages.
  Verify: release published

P977 | Post-release review
  File: AGENTS.md (modify)  Dep: P976
  What went well, what to improve for next release.
  Verify: review noted

P978 | Roadmap for v2.0
  File: ROADMAP.md (modify)  Dep: P977
  Plan for next major version.
  Verify: v2 roadmap started

P979 | Performance monitoring setup
  File: deploy/prometheus/prometheus.yml (create)  Dep: P978
  Prometheus config for scraping edge-proxy.
  Verify: Prometheus configured

P980 | Alertmanager setup
  File: deploy/prometheus/alertmanager.yml (create)  Dep: P979
  Alertmanager for production alerts.
  Verify: alertmanager configured

P981 | Grafana alerting
  File: deploy/grafana/alerting.yaml (create)  Dep: P980
  Grafana alerts for key metrics.
  Verify: alerts configured

P982 | SLA/SLO documentation
  File: docs/sla.md (create)  Dep: P981
  Document SLA targets: latency, uptime, throughput.
  Verify: SLA documented

P983 | Runbook creation
  File: docs/runbook.md (create)  Dep: P982
  Operational runbook: start, stop, diagnose, recover.
  Verify: runbook complete

P984 | Disaster recovery plan
  File: docs/disaster_recovery.md (create)  Dep: P983
  Backup, restore, migration procedures.
  Verify: DR plan documented

P985 | Production deployment guide
  File: docs/production.md (create)  Dep: P984
  Production deployment: sizing, tuning, monitoring.
  Verify: guide complete

P986 | Capacity planning guide
  File: docs/capacity_planning.md (create)  Dep: P985
  How to size edge-proxy for expected load.
  Verify: guide complete

P987 | Troubleshooting guide
  File: docs/troubleshooting.md (create)  Dep: P986
  Common issues and solutions.
  Verify: guide complete

P988 | FAQ document
  File: docs/faq.md (create)  Dep: P987
  Frequently asked questions.
  Verify: FAQ complete

P989 | Migration guide (from other proxies)
  File: docs/migration.md (create)  Dep: P988
  Migrating from nginx, haproxy, envoy.
  Verify: guide complete

P990 | Benchmark comparison document
  File: docs/benchmarks.md (create)  Dep: P989
  edge-proxy vs nginx vs haproxy vs envoy.
  Verify: comparison documented

P991 | Feature comparison matrix
  File: docs/features.md (create)  Dep: P990
  Feature comparison with other proxies.
  Verify: matrix complete

P992 | Performance tuning checklist
  File: docs/tuning_checklist.md (create)  Dep: P991
  Step-by-step tuning checklist.
  Verify: checklist complete

P993 | Security hardening checklist
  File: docs/security_checklist.md (create)  Dep: P992
  Security hardening steps.
  Verify: checklist complete

P994 | Monitoring setup checklist
  File: docs/monitoring_checklist.md (create)  Dep: P993
  Monitoring and alerting setup steps.
  Verify: checklist complete

P995 | Final project archive
  File: (all files)  Dep: P994
  Tag v1.0.0-final. Prepare archives.
  Verify: release ready

P996 | Thank contributors
  File: AUTHORS.md (create)  Dep: P995
  List of contributors.
  Verify: AUTHORS created

P997 | Celebrate v1.0
  File: (none)  Dep: P996
  edge-proxy v1.0.0 is complete! 1000 programs delivered.
  Verify: party

P998 | Plan v1.1 maintenance
  File: AGENTS.md (modify)  Dep: P997
  Bug fix and maintenance plan.
  Verify: plan documented

P999 | Community channels
  File: COMMUNITY.md (create)  Dep: P998
  Slack, mailing list, issue tracker.
  Verify: community page

P1000 | The future
  File: FUTURE.md (create)  Dep: P999
  Vision: HTTP/3, WebAssembly filters, eBPF data plane.
  Verify: future vision documented
```

### Final Folder Tree (P1000 — Complete)

```
edge-proxy/
├── CMakeLists.txt, .clang-format, .clang-tidy, .clangd
├── AGENTS.md, README.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, LICENSE
├── SUMMARY.md, ANNOUNCEMENT.md, AUTHORS.md, COMMUNITY.md, FUTURE.md
├── CHANGELOG.md, RELEASE_NOTES.md, RELEASE_CHECKLIST.md
├── Dockerfile, docker-compose.yml
├── logo.svg
├── include/
│   ├── core/     (types.hpp, platform.hpp, error.hpp, logger.hpp, config.hpp, version.hpp.in, seccomp.hpp)
│   ├── net/      (address.hpp, socket.hpp, epoll.hpp, connection.hpp, event_loop.hpp, tls.hpp, admin.hpp, ratelimit.hpp)
│   ├── http/     (method.hpp, header.hpp, request.hpp, response.hpp, parser.hpp)
│   │   └── h2/   (frame.hpp, settings.hpp, connection.hpp, stream.hpp, hpack.hpp, proxy.hpp)
│   ├── mem/      (slab.hpp, arena.hpp, pool.hpp, buffer.hpp, tracker.hpp)
│   ├── sync/     (spsc.hpp, thread_pool.hpp, affinity.hpp)
│   ├── io/       (io_uring.hpp, xdp.hpp)
│   ├── simd/     (scan.hpp)
│   └── telemetry/ (metrics.hpp, latency.hpp)
├── src/
│   ├── main.cpp
│   ├── core/     (error.cpp, logger.cpp, config.cpp, platform.cpp, seccomp.cpp)
│   ├── net/      (address.cpp, socket.cpp, epoll.cpp, connection.cpp, event_loop.cpp, tls.cpp, admin.cpp, ratelimit.cpp)
│   ├── http/     (method.cpp, header.cpp, request.cpp, response.cpp, parser.cpp)
│   │   └── h2/   (frame.cpp, settings.cpp, connection.cpp, hpack.cpp, proxy.cpp)
│   ├── mem/      (slab.cpp, arena.cpp, buffer.cpp, tracker.cpp)
│   ├── sync/     (spsc.cpp, thread_pool.cpp, affinity.cpp)
│   ├── io/       (io_uring.cpp, xdp.cpp)
│   ├── simd/     (scan.cpp)
│   └── telemetry/ (metrics.cpp, latency.cpp)
├── tests/
│   ├── unit/     (test_error, test_logger, test_config, test_socket, test_epoll,
│   │              test_connection, test_buffer, test_parser, test_slab, test_arena,
│   │              test_memory, test_thread_pool, test_affinity, test_spsc,
│   │              test_hash_ring, test_work_stealing, test_numa, test_io_uring,
│   │              test_simd, test_xdp, test_metrics, test_tls, test_ratelimit,
│   │              test_seccomp + CMakeLists.txt)
│   ├── integration/ (test_epoll_echo, test_proxy_basic, test_proxy_concurrent,
│   │                  test_proxy_errors, test_proxy_lifecycle, test_zero_alloc,
│   │                  test_heap_allocation, test_reuseport, test_worker_isolation,
│   │                  test_graceful_shutdown, test_multi_worker, test_memory_steady,
│   │                  test_simd_load, test_xdp_throughput, test_xdp_fallback,
│   │                  test_admin, test_ratelimit, test_dos_protection, test_tls_proxy,
│   │                  test_chaos, test_stability, test_h2 + CMakeLists.txt)
│   ├── fuzz/      (fuzz_parser, fuzz_config, fuzz_address + CMakeLists.txt)
│   └── load/      (run.sh)
├── benchmarks/    (BM_Logger, BM_Socket, BM_Epoll, BM_Connection, BM_Buffer,
│                   BM_Parser, BM_Proxy, BM_Slab, BM_Arena, BM_ThreadPool,
│                   BM_Numa, BM_Isolation, BM_Contention, BM_SPSC, BM_HashRing,
│                   BM_MultiWorker, BM_Scaling, BM_WorkStealing, BM_MemoryBandwidth,
│                   BM_IoUring, BM_SIMD, BM_XDP, BM_Metrics, BM_TLS, BM_Admin,
│                   BM_H2 + CMakeLists.txt)
├── scripts/       (benchmark.sh, profile.sh, run_load_test.sh, setup_dev.sh,
│                   bump_version.sh, generate_changelog.sh, capture_baseline.sh,
│                   latency_profile.sh, conn_scalability.sh, throughput_latency.sh,
│                   generate_perf_report.sh)
├── cmake/
├── docs/          (index.md, api.md, configuration.md, performance.md,
│                   deployment.md, security.md, sla.md, runbook.md,
│                   disaster_recovery.md, production.md, capacity_planning.md,
│                   troubleshooting.md, faq.md, migration.md, benchmarks.md,
│                   features.md, tuning_checklist.md, security_checklist.md,
│                   monitoring_checklist.md)
├── deploy/
│   ├── k8s/       (deployment.yaml, service.yaml, configmap.yaml, pdb.yaml,
│   │               hpa.yaml, servicemonitor.yaml)
│   ├── grafana/   (dashboard.json, alerting.yaml)
│   └── prometheus/ (prometheus.yml, alertmanager.yml, alerts.yaml)
├── packaging/     (edge-proxy.spec, debian/control, homebrew.rb, default.nix)
└── .github/workflows/ (ci.yml, benchmark.yml, release.yml, docker.yml)
```

---

## Epilogue

**1000 programs. One proxy. Built one program at a time.**

This roadmap decomposes edge-proxy into 1000 atomic, ordered programs. Each program produces a concrete artifact and can be verified independently. The strict ordering ensures each program builds on a solid foundation.

### Key Principles
- **Every program is verifiable** — a build step, test, or manual check proves it works.
- **Every program is atomic** — 5–100 lines of focused work.
- **Every program has one dependency** — the immediately preceding program it builds on.
- **Parallelism within a module** — later programs in a module often don't depend on earlier ones in the same module.
- **No cross-module parallelism** — modules are strictly ordered.

### How to Use
1. Start at P001. Complete it. Verify it.
2. Move to P002. Repeat.
3. Skip nothing. Each program depends on the previous.
4. Run the verify command before marking a program complete.

**The journey of 1000 programs begins with a single `cmake -B build && cmake --build build`.**
