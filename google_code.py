import pyotp
import sys
import time

# 请将 'your_base32_secret' 替换为你的密钥
#secret = 'DHY6PKNXOHQHLTNOCQOPTRFL4M'
secret = sys.argv[1]
# 创建一个 TOTP 对象
totp = pyotp.TOTP(secret)

# 生成当前时间的验证码
current_code = totp.now()
print("当前验证码:", current_code)

# 如果你想要特定时间的验证码，可以这样做
#timestamp = int(time.time())  # 当前时间戳
#code_at_time = totp.at(timestamp)
#print(f"时间戳 {timestamp} 的验证码:", code_at_time)