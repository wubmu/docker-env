## ADDED Requirements

### Requirement: 认证成功率分析
系统 SHALL 提供认证数据分析功能，用于计算和展示认证成功率、失败原因、各认证方式统计以及租户维度的分析。

#### Scenario: 成功分析认证数据
- **WHEN** 系统接收到认证记录的 JSON 数组输入
- **THEN** 系统返回包含以下信息的结构化 JSON：
  - 所有认证失败的详细信息列表（包括时间戳、租户ID、用户名、认证方式、失败原因等）
  - 总体认证成功率（成功次数 / 总次数）
  - 各认证方式（login_type）的成功率、总次数、成功次数、失败次数
  - 各认证方式的失败原因统计（按原因分组统计次数）
  - 每个租户（tid）的总体成功率
  - 每个租户下各认证方式的成功率、次数统计

#### Scenario: 处理空数据输入
- **WHEN** 输入的认证记录数组为空或未定义
- **THEN** 系统返回包含零统计数据的结构化 JSON，不会抛出错误

#### Scenario: 处理无失败记录的情况
- **WHEN** 所有认证记录的 result 字段均为 true（无失败记录）
- **THEN** 系统返回失败记录列表为空，其他统计数据正常计算

#### Scenario: 多租户数据统计
- **WHEN** 输入数据包含多个不同租户（tid）的认证记录
- **THEN** 系统按租户分组计算每个租户的统计数据，包括：
  - 该租户的总体成功率
  - 该租户使用的各认证方式的统计信息

#### Scenario: 认证方式分组统计
- **WHEN** 输入数据包含多种认证方式（如 v.sms, v.password 等）
- **THEN** 系统按认证方式分组计算每个方式的：
  - 成功率
  - 总尝试次数
  - 成功次数
  - 失败次数
  - 失败原因及次数统计

#### Scenario: JavaScript 脚本执行
- **WHEN** 在 n8n 中使用 JavaScript 运行器执行 `auth-success-rate-analysis.js`
- **THEN** 脚本从输入参数 `input` 中获取认证记录数组，并返回分析结果

#### Scenario: Python 脚本执行
- **WHEN** 在 n8n 中使用 Python 运行器执行 `auth-success-rate-analysis.py`
- **THEN** 脚本从标准输入读取 JSON 数据，并输出分析结果到标准输出