import os
import cv2
import numpy as np
from tqdm import tqdm
from sklearn.utils.class_weight import compute_class_weight

from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import (
    Conv2D, MaxPooling2D, Flatten,
    Dense, Dropout, BatchNormalization
)
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau

# =========================
# 1️⃣ 基本设置
# =========================
IMG_SIZE = 48
BATCH_SIZE = 32
EPOCHS = 50

TRAIN_DIR = "../dataset/train"
TEST_DIR = "../dataset/test"

CATEGORIES = [
    "angry", "disgust", "fear", "sad"
]

# =========================
# 2️⃣ 数据载入函数
# =========================
def load_data(base_dir):
    X, y = [], []

    for idx, category in enumerate(CATEGORIES):
        folder = os.path.join(base_dir, category)
        print(f"📂 Loading {category} from {base_dir}")

        for file in tqdm(os.listdir(folder)):
            img_path = os.path.join(folder, file)
            img = cv2.imread(img_path)

            if img is None:
                continue

            img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            img_gray = cv2.resize(img_gray, (IMG_SIZE, IMG_SIZE))
            img_gray = img_gray / 255.0

            X.append(img_gray)
            y.append(idx)

    X = np.array(X).reshape(-1, IMG_SIZE, IMG_SIZE, 1)
    y = np.array(y)

    return X, y

# =========================
# 3️⃣ 载入 train / test
# =========================
X_train, y_train = load_data(TRAIN_DIR)
X_test, y_test = load_data(TEST_DIR)

y_train_cat = to_categorical(y_train, num_classes=len(CATEGORIES))
y_test_cat = to_categorical(y_test, num_classes=len(CATEGORIES))

# =========================
# 4️⃣ 类别权重（非常关键）
# =========================
class_weights = compute_class_weight(
    class_weight="balanced",
    classes=np.unique(y_train),
    y=y_train
)
class_weights = dict(enumerate(class_weights))
print("⚖️ Class weights:", class_weights)

# =========================
# 5️⃣ CNN 模型
# =========================
model = Sequential([
    Conv2D(32, (3, 3), activation="relu", input_shape=(48, 48, 1)),
    BatchNormalization(),
    MaxPooling2D(2, 2),

    Conv2D(64, (3, 3), activation="relu"),
    BatchNormalization(),
    MaxPooling2D(2, 2),

    Conv2D(128, (3, 3), activation="relu"),
    BatchNormalization(),
    MaxPooling2D(2, 2),

    Flatten(),
    Dense(256, activation="relu"),
    Dropout(0.6),

    Dense(len(CATEGORIES), activation="softmax")
])

model.compile(
    optimizer="adam",
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)

# =========================
# 6️⃣ Callbacks（安全版）
# =========================
callbacks = [
    ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.3,
        patience=4,
        min_lr=1e-5,
        verbose=1
    ),
    EarlyStopping(
        monitor="val_loss",
        patience=10,          # 很难提前停
        min_delta=0.001,
        restore_best_weights=True,
        verbose=1
    )
]

# =========================
# 7️⃣ 训练
# =========================
model.fit(
    X_train, y_train_cat,
    validation_data=(X_test, y_test_cat),
    epochs=EPOCHS,
    batch_size=BATCH_SIZE,
    class_weight=class_weights,
    callbacks=callbacks
)

# =========================
# 8️⃣ 保存模型
# =========================
model.save("emotion_model.h5")
print("✅ Training finished & model saved")
