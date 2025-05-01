import pandas as pd
import numpy as np
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense

# Load dataset
df = pd.read_csv("transaction_year_2025.csv")
# More flexible date parsing
df['date'] = pd.to_datetime(df['date'], errors='coerce')
# df['date'] = pd.to_datetime(df['date'], format="%d/%m/%Y", errors="coerce")
# Clean 'amount' column by removing commas, ₹ symbols, etc.
df['amount'] = df['amount'].astype(str).str.replace(r'[^\d.]', '', regex=True)
df['amount'] = pd.to_numeric(df['amount'], errors='coerce')
# Drop rows with invalid data
df.dropna(subset=["date", "amount"], inplace=True)

df['day'] = df['date'].dt.day
df['month'] = df['date'].dt.month
df['year'] = df['date'].dt.year

def classify_priority(amount):
    if amount > 1000: return 'High'
    elif amount > 500: return 'Medium'
    else: return 'Low'

def classify_level(amount):
    if amount > 1500: return 'Very High'
    elif amount > 1000: return 'High'
    elif amount > 500: return 'Moderate'
    elif amount > 100: return 'Low'
    else: return 'Very Low'

df['priority'] = df['amount'].apply(classify_priority)
df['level'] = df['amount'].apply(classify_level)


print("Raw Data Preview:")
print(df.head())
print("DataFrame Columns:", df.columns.tolist())


le_priority = LabelEncoder()
le_level = LabelEncoder()
df['priority_encoded'] = le_priority.fit_transform(df['priority'])
df['level_encoded'] = le_level.fit_transform(df['level'])

features = ['amount', 'day', 'month', 'year']
X = df[features]
y_priority = df['priority_encoded']
y_level = df['level_encoded']

print(f"🔍 Total samples available for training: {len(X)}")
if len(X) == 0:
    raise ValueError("🚫 ERROR: No samples available after preprocessing. Check your CSV input and preprocessing steps.")
    
X_train, X_test, y_train_p, y_test_p = train_test_split(X, y_priority, test_size=0.2)

clf_priority = RandomForestClassifier().fit(X_train, y_train_p)

X_train, X_test, y_train_l, y_test_l = train_test_split(X, y_level, test_size=0.2)
clf_level = RandomForestClassifier().fit(X_train, y_train_l)

with open("clf_priority.pkl", "wb") as f:
    pickle.dump(clf_priority, f)

with open("clf_level.pkl", "wb") as f:
    pickle.dump(clf_level, f)

# LSTM prediction
df.sort_values('date', inplace=True)
amounts = df['amount'].values
scaler = StandardScaler()
scaled_amounts = scaler.fit_transform(amounts.reshape(-1, 1))

def create_sequences(data, seq_length=5):
    X, y = [], []
    for i in range(len(data) - seq_length):
        X.append(data[i:i + seq_length])
        y.append(data[i + seq_length])
    return np.array(X), np.array(y)

X_seq, y_seq = create_sequences(scaled_amounts)
X_seq = X_seq.reshape((X_seq.shape[0], X_seq.shape[1], 1))

model = Sequential()
model.add(LSTM(50, activation='relu', input_shape=(X_seq.shape[1], 1)))
model.add(Dense(1))
model.compile(optimizer='adam', loss='mse')
model.fit(X_seq, y_seq, epochs=10, verbose=1)

model.save("lstm_model.keras")

with open("scaler.pkl", "wb") as f:
    pickle.dump(scaler, f)
