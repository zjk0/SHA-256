# SHA-256 测试向量与预期哈希值 (17-9)

> FIPS 180-4 官方测试向量，用于 RTL 仿真和门级后仿验证。

## 1. 测试向量总览

| # | 输入 | 长度 | 预期 SHA-256 | 来源 |
|---|------|------|-------------|------|
| 1 | `""` (空串) | 0 bit | `e3b0c442...b855` | FIPS 180-4 |
| 2 | `"abc"` | 24 bit | `ba7816bf...15ad` | FIPS 180-4 |
| 3 | `"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"` | 448 bit | `248d6a61...06c1` | FIPS 180-4 |
| 4 | 1,000,000 × `"a"` | 8,000,000 bit | `cdc76e5c...12cd0` | FIPS 180-4 |

## 2. 详细哈希值

### 向量 1: 空串

```
输入: (无)
输入长度: 0 bit
预期哈希: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

验证要点：空串的 SHA-256 是一个众所周知的常数，任何实现都应产生此结果。

### 向量 2: "abc"

```
输入: abc
输入长度: 24 bit (3 字节)
预期哈希: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
```

验证要点：这是最常用的 SHA-256 测试向量，出现在几乎所有密码学教材中。

### 向量 3: 多块消息

```
输入: abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq
输入长度: 448 bit (56 字节)
预期哈希: 248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1
```

验证要点：448 bit 消息加上填充和长度字段后需要两个 512-bit 块，可用于将来验证多块处理逻辑。

### 向量 4: 百万字符

```
输入: 1,000,000 个 "a"
输入长度: 8,000,000 bit (1,000,000 字节)
预期哈希: cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0
```

验证要点：大规模输入，测试长消息处理和内存管理。当前 RTL 缺少多块链接状态，因此未覆盖此向量。

## 3. 本项目验证结果

| 向量 | RTL 仿真 | 门级后仿 (Post-PnR) | 状态 |
|------|---------|-------------------|------|
| 1: 空串 | PASS | PASS | ✅ |
| 2: "abc" | PASS | PASS | ✅ |
| 3: 多块 | 当前 RTL 不支持 | 当前 RTL 不支持 | 不在验证范围 |
| 4: 百万字符 | 未测 | 未测 | ⚠️ (可选) |

> 向量 1 和 2 都是单块消息。当前 `wvar.v` 在每次 `soc` 时重载固定 IV，尚不支持跨块链接。历史后仿结果与本机新运行结果应区分。

## 4. 输入格式说明

独立核心接口是 `data_in[31:0]`、`data_out[31:0]`、`data_oe` 和 `clk/rst/soc/rd/eoc`，并非 Wishbone。`caravel/` 才是独立的 Wishbone 集成草案。

以 `abc` 为例，填充后的输入字为 `0x61626380`、14 个零字、`0x00000018`，共 16 字（512 bit）。输出按 H0～H7 读取 8 个 32-bit 字。

## 5. 运行测试

从项目根目录执行：

```bash
./flow/run_sim.sh rtl
./flow/run_synth.sh
./flow/run_sim.sh synth
# OpenROAD 完成、生成 SHA256_15ns_final.v 后：
./flow/run_sim.sh gate
```

三个模式均使用 `flow/fips_180_4_post_sim_tb.v`。综合网表和布局后网表使用安装 PDK 的标准单元功能模型，未回标 SDF；物理时序需另看 STA。`Verilog/SHA256_testbench.v` 保留了旧接口，不能使用其原来的编译命令测试当前 RTL。

## 6. 参考资源

- [FIPS 180-4 标准](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf)
- [SHA-256 Algorithm Explained](https://sha256algorithm.com/) — 交互式可视化
- [NIST CSRC Test Vectors](https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/secure-hashing) — 官方测试向量
