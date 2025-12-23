import tensorflow as tf

# 1️⃣ 加载训练好的模型
model = tf.keras.models.load_model('emotion_model.h5')

# 2️⃣ 创建 TFLite 转换器
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# 3️⃣ 保存为 TFLite 文件
with open('emotion_model.tflite', 'wb') as f:
    f.write(tflite_model)

print("✅ 转换完成！已保存为 emotion_model.tflite")
