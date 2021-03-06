from transformers import T5Tokenizer, AutoModelForCausalLM
import math

# トークナイザーとモデルの準備
tokenizer = T5Tokenizer.from_pretrained("rinna/japanese-gpt2-medium")
model = AutoModelForCausalLM.from_pretrained("rinna/japanese-gpt2-medium")

# 推論
input = tokenizer.encode("昔々あるところに", return_tensors="pt")
output = model.generate(input, do_sample=True, max_length=30, num_return_sequences=3)
print(tokenizer.batch_decode(output))
