# reproduce-CUE-R
R语言复现：氮添加对土壤微生物碳利用效率影响研究。
---

## 3. 数据说明
文件：extracted_data.csv
每一行代表一项来自田间试验的观测（效应量对比），用于分析氮添加对微生物碳利用效率（CUE）的影响。
数据集包含氮处理组与对照组的均值、标准差、样本量，以及环境调节变量。

| 列名 | 说明 |
| ---- | ---- |
| obs | 观测编号，每条记录唯一 |
| Site | 站点编码或研究标识 |
| Latitude | 研究站点纬度（十进制度） |
| Longitude | 研究站点经度（十进制度） |
| tm | 氮处理组微生物CUE均值 |
| ts | 氮处理组CUE标准差 |
| tn | 氮处理组样本量 |
| cm | 对照组微生物CUE均值 |
| cs | 对照组CUE标准差 |
| cn | 对照组样本量 |
| MAP | 年均降水量（mm），分组变量 |
| N_addtion | 氮添加水平（如<100、100–200、>200 kg N ha⁻¹ yr⁻¹），分类变量 |
| pH | 土壤pH |
| MAT | 年均气温（℃） |
| SOC | 土壤有机碳含量（g kg⁻¹） |
| TN | 土壤全氮含量（g kg⁻¹） |
| TP | 土壤全磷含量（g kg⁻¹） |
| CNR | 土壤碳氮比 |
| NPR | 土壤氮磷比 |
| MBC | 微生物生物量碳（mg kg⁻¹） |
| MBN | 微生物生物量氮（mg kg⁻¹） |
| MCNR | 微生物碳氮比（无单位） |

缺失值使用 NA 表示。

---

## 5. 引用

若使用本数据集或代码，请按以下格式引用：

Yin, T., et al. (2025). Dataset and code for "Meta-analysis and Machine Learning Reveal Key Drivers of Microbial Carbon Use Efficiency Under Nitrogen Enrichment"

---

## 6. 许可协议

本仓库基于知识共享署名 4.0 国际许可协议（CC BY 4.0）授权。

只要注明适当出处，您可出于任何目的（包括商业用途）自由分享和改编本材料。

---
