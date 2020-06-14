import pandas as pd
import seaborn as sns

df = pd.read_csv('averages.csv')
df = df[df.congress == 0]
df['plus_minus'] = df["agree_pct"] - df["predicted_agree"]
df2 = df[['party', 'last_name', 'state', 'district', 'agree_pct', 'predicted_agree', 'plus_minus']]
df2.district = df2.district.astype(str)
df2 = df2.sort_values('plus_minus')
df2 = df2.dropna()

cm = sns.diverging_palette(220, 10, sep=80, as_cmap=True)
s = (df2.style
        .background_gradient(cmap=cm)
        .set_precision(1)
        .hide_index())
with open('table.html', 'w') as f:
    f.write(s.render())

