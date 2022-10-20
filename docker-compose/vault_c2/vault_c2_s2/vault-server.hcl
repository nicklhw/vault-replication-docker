storage "raft" {
  path = "/vault/data"
  node_id = "vault_s2"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/vault_c2_chain.crt"
  tls_key_file = "/vault/config/vault_c2.key"
}

api_addr = "https://vault_c2_s2:8200"
cluster_addr = "https://vault_c2_s2:8201"

ui = "true"

license_path = "/vault/config/vault.hclic"

seal "awskms" {
  region     = "ca-central-1"
  access_key = "ASIAQI5S3I4IVU3AXP7I"
  secret_key = "YV1GUcX/oFVmV3Kp9VOYiV2zu/aSbULuVhtA/ci2"
  session_token = "IQoJb3JpZ2luX2VjEIb//////////wEaCXVzLXdlc3QtMiJHMEUCIQCgwMGMjKwft/DZkPwSNwU8dzJSILEqsxrgQBr2ziilKAIgL1dMmtaWN4um3OCMpXQBP3Ild5uZLqd5OJbxKZ4eBREq3QQIXxACGgwwMTkxNjU1NjI2NDEiDEtMl2XwF6VIRGnXVyq6BBmOv+KymHuTDP914l+dDc+voqBpREmjrG0O/uA0wFsbsODQoe7B2cXEI7fulIkKx8hwcK/7kbvkt6PIufL+zhTcCrhtTbTqlr637KYogOSAOKpuAeLZgqMJuTPVZKBmZPM1hWEClj3pYwssjYRfX2pW+we1f6GWEmrNa+5mJPB6N/I12/uBxUxdyZ7c6xlmwIEYscuZz0nhKJWXW/DesapVlu81PViRe4wZxeuc0M8yHncmS5bZ3C6kojQQG3LJNmtMhEBGZn3NNH2XulDutrRYPlvhBls2AhshNDhceoCcle5krIHMaTQglNYCiNrrrCvxywEgrUb5SFsGZgIGQ5Y4CE2i+E6VVPdbkRFVE4UYZbKR6o0MRlb8mhijezFPMgVmf8uWxx/qYaz/esZzcJR59lRk3Gi8XTcXcHfpveq8pNYcJbSo+3Vk695q4uzq4sDTAipEnhxNKdsAf3kGchGl75LZvj858Ep7l8aDdZf/MZwEXuGY5C1WD1sauI8c5uQMkJegEyQt9VOWMcOLksa6mlmp0wpsQWow1hx387a3uPk3KnMKkrdRFeEtTsdtmED9cZAYE0mcp4xE7hd5LtSIe3zOsUl5o4sW9ukMjUKfIh7YZroSnSFFihy0jcLLUxZdX58M1UWNSxAsGGJfVI43BKsDxXyVTXLhINhKMaXZKMnPBi7cGnvM96o0SaE8vAG2i+EgpQcwJZFaIppwHTuhTRN5NkB65d86C+zrOcdTiBrvkWEYi0ExvTCypMWaBjqhAVWJRKwOtbRqegObCPLfPqla70mL9QfsfxSNAg/h51dlN8Gu1uMIOJjPZ2Rzp4ngNHrSgsE+dqwlH02hvbO0Co8yPZFFWd1+1ysuADl1QvpwVRsn/GwJ/v45jCnMMyoW6n43XYTzAD/Mc9PRa2he56zBCO8SLWsUrylriP5zEb4x6+3w8AOGl1aCNAsvQkwkptBMmAmaDm6T+7jMO1EO2xgM"
  kms_key_id = "0f71badb-ff9f-4ecf-98a8-913c8b939619"
}