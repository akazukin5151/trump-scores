using CSV
using GLM
using Plots
using DataFrames

df = DataFrame(CSV.File("averages.csv"))

# Filter out different congresses, only look at overall
df = df[df.congress .== 0, :]
# plus-minus score is (actual trump score) - (predicted trump score)
# A negative score indicates they oppose Trump more than their district
# A positive score indicates they favour Trump more than their district
df."plus_minus" = df."agree_pct" - df."predicted_agree"
df2 = select(df, [:party, :last_name, :agree_pct, :predicted_agree, :plus_minus])
sort!(df2, :plus_minus)

# Linear regressions
r = df2[df2.party .== "Republican", :]
d = df2[df2.party .== "Democrat", :]
ols_r = lm(@formula(predicted_agree ~ agree_pct), r)
ols_d = lm(@formula(predicted_agree ~ agree_pct), d)

# Plot everything in one pic
scatter = begin
    plot(r.predicted_agree, r.agree_pct, seriestype = :scatter, c = :red, alpha = 0.5,
         legend = false, xlims=(0, 1), ylims = (0,1))
    plot!(d.predicted_agree, d.agree_pct, seriestype = :scatter, c = :blue, alpha = 0.5)
    plot!(predict(ols_d), d.agree_pct, c = :blue)
    plot!(predict(ols_r), r.agree_pct, c = :red)
end

# Histograms
histograms = begin
    histogram(r.predicted_agree, r.agree_pct, c=:red, bins=40, alpha=0.5, legend=false)
    histogram!(d.predicted_agree, d.agree_pct, c = :skyblue, bins = 40, alpha = 0.5)
end

heatmaps = plot(
    histogram2d(r.predicted_agree, r.agree_pct, nbins=40, clims=(0,25), xlims=(0,1)),
    histogram2d(d.predicted_agree, d.agree_pct, nbins=40, clims=(0,25), xlims=(0,1)),
    link = :both
)

# Scatter + regression & heatmaps & histograms
plot(scatter, histograms, heatmaps, layout = @layout[a b; c], size=(1000, 1000))
savefig("trump_scores.png")

