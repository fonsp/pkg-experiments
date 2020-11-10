### A Pluto.jl notebook ###
# v0.12.7

using Markdown
using InteractiveUtils

# ╔═╡ 52305f60-2380-11eb-0a3b-6f693199061f
using Test

# ╔═╡ d0b0df40-238f-11eb-34b4-0f3ed25ed387
input = "Stati"

# ╔═╡ 98cd6600-2391-11eb-27ce-db2d65320b83
function registries_path(registries, package_name)
	for (rpath, r) in registries
		packages = values(r["packages"])
		ds = Iterators.filter(d -> d["name"] == package_name, packages)
		if !isempty(ds)
			return joinpath(rpath, first(ds)["path"])
		end
	end
end

# ╔═╡ 6a921012-2382-11eb-1e80-7fa5613b33fe
import Pkg

# ╔═╡ fe905760-238f-11eb-1cc0-ebb3852a20de
registry_paths = @static if isdefined(Pkg.Types, :registries)
	Pkg.Types.registries()
else
	registry_specs = Pkg.Types.collect_registries()
	[s.path for s in registry_specs]
end

# ╔═╡ 1cea1de0-2390-11eb-1b76-21cd0039d5a3
registries = map(registry_paths) do r
	r => Pkg.Types.read_registry(joinpath(r, "Registry.toml"))
end

# ╔═╡ 4f502502-238f-11eb-010e-2bd4f4ad54ac
# Pkg.Types.stdlibs()

# ╔═╡ 57e25bc0-238f-11eb-3ca4-9900e4c37722
ctx = Pkg.Types.Context()

# ╔═╡ 7b5add20-238f-11eb-1217-453e2d37d344
function packagecompletions(partial_name)
	@static if hasmethod(Pkg.REPLMode.complete_remote_package, (String,))
		Pkg.REPLMode.complete_remote_package(partial_name)
	else
		Pkg.REPLMode.complete_remote_package(partial_name, 1, length(partial_name))[1]
	end
end

# ╔═╡ 648b5340-238f-11eb-0b68-efb3de51a08c
suggestions = isempty(input) ? [] : packagecompletions(input)

# ╔═╡ 66d54340-238f-11eb-3648-276b79333215
choice = first(suggestions)

# ╔═╡ 0ffd0690-2392-11eb-22e0-03e853615d65
choice_fullpath = registries_path(registries, choice)

# ╔═╡ 686e59d0-238f-11eb-3f12-bf477e76da93
choice_versions = (@static if hasmethod(Pkg.Operations.load_versions, (String,))
	Pkg.Operations.load_versions(choice_fullpath)
else
	Pkg.Operations.load_versions(ctx, choice_fullpath)
end) |> keys |> collect |> sort!

# ╔═╡ 744e54a0-2392-11eb-1bcb-b122f423aa21
@test length(choice_versions) > 25

# ╔═╡ d5d5b4a0-238f-11eb-3abf-2d2e30b9db08
@test length(suggestions) > 10

# ╔═╡ 8db62de0-2398-11eb-1010-354285451686
md"""
# Standard Libraries
"""

# ╔═╡ 45229422-2397-11eb-3086-5b7ffc864025
stdlibs = readdir(Pkg.Types.stdlib_dir())

# ╔═╡ 9725f362-2398-11eb-2c68-994a991385ff
@test "Dates" ∈ stdlibs

# ╔═╡ 9ba253c0-2398-11eb-367b-b93d59a4fa4d


# ╔═╡ Cell order:
# ╠═d0b0df40-238f-11eb-34b4-0f3ed25ed387
# ╠═648b5340-238f-11eb-0b68-efb3de51a08c
# ╠═66d54340-238f-11eb-3648-276b79333215
# ╠═d5d5b4a0-238f-11eb-3abf-2d2e30b9db08
# ╠═0ffd0690-2392-11eb-22e0-03e853615d65
# ╠═686e59d0-238f-11eb-3f12-bf477e76da93
# ╠═744e54a0-2392-11eb-1bcb-b122f423aa21
# ╠═98cd6600-2391-11eb-27ce-db2d65320b83
# ╠═52305f60-2380-11eb-0a3b-6f693199061f
# ╠═6a921012-2382-11eb-1e80-7fa5613b33fe
# ╠═fe905760-238f-11eb-1cc0-ebb3852a20de
# ╠═1cea1de0-2390-11eb-1b76-21cd0039d5a3
# ╠═4f502502-238f-11eb-010e-2bd4f4ad54ac
# ╠═57e25bc0-238f-11eb-3ca4-9900e4c37722
# ╠═7b5add20-238f-11eb-1217-453e2d37d344
# ╟─8db62de0-2398-11eb-1010-354285451686
# ╠═45229422-2397-11eb-3086-5b7ffc864025
# ╠═9725f362-2398-11eb-2c68-994a991385ff
# ╠═9ba253c0-2398-11eb-367b-b93d59a4fa4d
