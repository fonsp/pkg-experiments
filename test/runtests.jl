### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 52305f60-2380-11eb-0a3b-6f693199061f
using Test

# ╔═╡ 6235feb0-28cb-11eb-1754-8fc9b563ce19
using UUIDs

# ╔═╡ 6a921012-2382-11eb-1e80-7fa5613b33fe
import Pkg

# ╔═╡ 58ebcf22-28b6-11eb-1bf5-a3a07ba19de6
md"""
# Searching for packages
"""

# ╔═╡ d0b0df40-238f-11eb-34b4-0f3ed25ed387
input = "Pl"

# ╔═╡ 7b5add20-238f-11eb-1217-453e2d37d344
function registered_packagecompletions(partial_name)
	@static if hasmethod(Pkg.REPLMode.complete_remote_package, (String,))
		Pkg.REPLMode.complete_remote_package(partial_name)
	else
		Pkg.REPLMode.complete_remote_package(partial_name, 1, length(partial_name))[1]
	end
end

# ╔═╡ 648b5340-238f-11eb-0b68-efb3de51a08c
suggestions = isempty(input) ? [] : registered_packagecompletions(input)

# ╔═╡ 66d54340-238f-11eb-3648-276b79333215
choice = "Pluto"

# ╔═╡ d5d5b4a0-238f-11eb-3abf-2d2e30b9db08
@test length(suggestions) > 10

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

# ╔═╡ 82fd0130-28b6-11eb-3579-99308d152898
md"""
# Versions
"""

# ╔═╡ 9e3d2ba2-28b6-11eb-3056-dff56f475a9f
md"""
# Registry
"""

# ╔═╡ fe905760-238f-11eb-1cc0-ebb3852a20de
registry_paths = @static if isdefined(Pkg.Types, :registries)
	Pkg.Types.registries()
else
	registry_specs = Pkg.Types.collect_registries()
	[s.path for s in registry_specs]
end

# ╔═╡ 9f6753c2-28b6-11eb-0b73-7fdf2a02952d
@test all(ispath, registry_paths)

# ╔═╡ acbc90d0-28b6-11eb-374e-1bb48d7906f7
@test !isempty(registry_paths)

# ╔═╡ 1cea1de0-2390-11eb-1b76-21cd0039d5a3
registries = map(registry_paths) do r
	r => Pkg.Types.read_registry(joinpath(r, "Registry.toml"))
end

# ╔═╡ 0ffd0690-2392-11eb-22e0-03e853615d65
choice_fullpath = registries_path(registries, choice)

# ╔═╡ 75f065e2-28b6-11eb-0f94-8befbf9a78fd
@test ispath(choice_fullpath)

# ╔═╡ 57e25bc0-238f-11eb-3ca4-9900e4c37722
ctx = Pkg.Types.Context()

# ╔═╡ a26978c0-28cd-11eb-1234-351a08e5f214
function load_versions(registry_entry_fullpath::AbstractString)
	@static if hasmethod(Pkg.Operations.load_versions, (String,))
        Pkg.Operations.load_versions(registry_entry_fullpath)
    else
        Pkg.Operations.load_versions(ctx, registry_entry_fullpath)
    end
end

# ╔═╡ 879a388e-28cd-11eb-306e-57a3d69cf96e
function package_versions_from_path(registry_entry_fullpath::AbstractString)::Vector{VersionNumber}
    load_versions(registry_entry_fullpath) |> keys |> collect |> sort!
end

# ╔═╡ 686e59d0-238f-11eb-3f12-bf477e76da93
choice_versions = package_versions_from_path(choice_fullpath)

# ╔═╡ 744e54a0-2392-11eb-1bcb-b122f423aa21
@test length(choice_versions) > 25

# ╔═╡ 8db62de0-2398-11eb-1010-354285451686
md"""
# Standard Libraries
"""

# ╔═╡ 45229422-2397-11eb-3086-5b7ffc864025
stdlibs = readdir(Pkg.Types.stdlib_dir())

# ╔═╡ 9725f362-2398-11eb-2c68-994a991385ff
@test "Dates" ∈ stdlibs

# ╔═╡ 9ba253c0-2398-11eb-367b-b93d59a4fa4d
function packagecompletions(partial_name)
	[
		filter(s -> startswith(s,partial_name), stdlibs);
		registered_packagecompletions(partial_name)
	]
end

# ╔═╡ e983eb30-2398-11eb-26e3-2f5381ee19a1
input2 = "Dat"

# ╔═╡ f16a2a80-2398-11eb-3b3c-790a6adb891c
suggestions2 = packagecompletions(input2)

# ╔═╡ f6a87b50-2398-11eb-23a4-11a2d74cf49a
@test suggestions2[1] == "Dates"

# ╔═╡ 02a99a10-2399-11eb-2040-131ed61481ae
@test length(suggestions2) > 10

# ╔═╡ 02716120-239b-11eb-1244-0790c6dbf2b6
stdlib_paths = let
	d = Pkg.Types.stdlib_dir()
	joinpath.([d], readdir(d))
end

# ╔═╡ 8964e340-28c9-11eb-37b4-0dabd66fabf2
md"""
# Getting the UUID
"""

# ╔═╡ 8e0ac4a0-28c9-11eb-3405-d5315ac0b715
function registered_uuids(pkg_name::String)::Vector{UUID}
	@static if hasmethod(Pkg.Types.registered_uuids, (Pkg.Types.Context, String))
			Pkg.Types.registered_uuids(ctx, pkg_name)
		else
			Pkg.Types.registered_uuids(ctx.env, pkg_name)
		end
end

# ╔═╡ 2d896d82-28cd-11eb-3d27-9d69b4068649
pluto_uuid = UUID("c3e4b0f8-55cb-11ea-2926-15256bba5781")

# ╔═╡ 2bffa090-28ca-11eb-10a3-c5f854053da3
@test registered_uuids("Pluto") == [pluto_uuid]

# ╔═╡ c6343040-28b6-11eb-35c2-8dd37773fb1c
md"""
# Downloaded
"""

# ╔═╡ e30f9cb0-28cd-11eb-3236-4770e2c17412
choice_fullpath

# ╔═╡ dbb0b5d2-28cd-11eb-2e78-279dca23052e
load_versions(choice_fullpath)

# ╔═╡ fbfaac30-28d0-11eb-2e70-2f6e33f6f0c3


# ╔═╡ ca107380-28cb-11eb-146b-67cb40cfcfa2
function is_downloaded(pkg_name, version::VersionNumber)
	uuids = registered_uuids(pkg_name)
	
	full_path = registries_path(registries, pkg_name)
	
	versions_dict = load_versions(full_path)
	
	tree_hash = versions_dict[version]
	
	
# 	p = Pkg.Operations.PackageSpec(
# 		name=pkg_name,
# 		uuid=first(uuids),
# 		version=version,
# 		tree_hash=tree_hash,
# 	)
# 	# p = Pkg.Operations.source_path(ctx, )
	
	
# 	Pkg.Operations.is_package_downloaded(ctx, p)
	
	path = Pkg.Operations.find_installed(pkg_name, first(uuids), tree_hash)
	ispath(path)
end

# ╔═╡ 2e5b3fa2-28d1-11eb-3fab-ad91df79562e


# ╔═╡ 70c71b50-28c4-11eb-243d-e7fbf26c9d04
@test is_downloaded("PlutoUI", v"0.6.5")

# ╔═╡ 76a2aaa0-28d1-11eb-111a-652bb440adc2
@test !is_downloaded("PlutoUI", v"0.6.4")

# ╔═╡ 8c283b3e-28c4-11eb-171f-9d4b01bb6082


# ╔═╡ 6b92194e-28c4-11eb-3775-ebcc7d10b249
# PlutoRunner.cell_results

# ╔═╡ Cell order:
# ╠═52305f60-2380-11eb-0a3b-6f693199061f
# ╠═6a921012-2382-11eb-1e80-7fa5613b33fe
# ╟─58ebcf22-28b6-11eb-1bf5-a3a07ba19de6
# ╠═d0b0df40-238f-11eb-34b4-0f3ed25ed387
# ╠═7b5add20-238f-11eb-1217-453e2d37d344
# ╠═648b5340-238f-11eb-0b68-efb3de51a08c
# ╠═66d54340-238f-11eb-3648-276b79333215
# ╠═d5d5b4a0-238f-11eb-3abf-2d2e30b9db08
# ╠═98cd6600-2391-11eb-27ce-db2d65320b83
# ╠═0ffd0690-2392-11eb-22e0-03e853615d65
# ╠═75f065e2-28b6-11eb-0f94-8befbf9a78fd
# ╟─82fd0130-28b6-11eb-3579-99308d152898
# ╠═a26978c0-28cd-11eb-1234-351a08e5f214
# ╠═879a388e-28cd-11eb-306e-57a3d69cf96e
# ╠═686e59d0-238f-11eb-3f12-bf477e76da93
# ╠═744e54a0-2392-11eb-1bcb-b122f423aa21
# ╟─9e3d2ba2-28b6-11eb-3056-dff56f475a9f
# ╠═fe905760-238f-11eb-1cc0-ebb3852a20de
# ╠═9f6753c2-28b6-11eb-0b73-7fdf2a02952d
# ╠═acbc90d0-28b6-11eb-374e-1bb48d7906f7
# ╠═1cea1de0-2390-11eb-1b76-21cd0039d5a3
# ╠═57e25bc0-238f-11eb-3ca4-9900e4c37722
# ╟─8db62de0-2398-11eb-1010-354285451686
# ╠═45229422-2397-11eb-3086-5b7ffc864025
# ╠═9725f362-2398-11eb-2c68-994a991385ff
# ╠═9ba253c0-2398-11eb-367b-b93d59a4fa4d
# ╠═e983eb30-2398-11eb-26e3-2f5381ee19a1
# ╠═f16a2a80-2398-11eb-3b3c-790a6adb891c
# ╠═f6a87b50-2398-11eb-23a4-11a2d74cf49a
# ╠═02a99a10-2399-11eb-2040-131ed61481ae
# ╠═02716120-239b-11eb-1244-0790c6dbf2b6
# ╟─8964e340-28c9-11eb-37b4-0dabd66fabf2
# ╠═8e0ac4a0-28c9-11eb-3405-d5315ac0b715
# ╠═6235feb0-28cb-11eb-1754-8fc9b563ce19
# ╠═2d896d82-28cd-11eb-3d27-9d69b4068649
# ╠═2bffa090-28ca-11eb-10a3-c5f854053da3
# ╟─c6343040-28b6-11eb-35c2-8dd37773fb1c
# ╠═e30f9cb0-28cd-11eb-3236-4770e2c17412
# ╠═dbb0b5d2-28cd-11eb-2e78-279dca23052e
# ╠═fbfaac30-28d0-11eb-2e70-2f6e33f6f0c3
# ╠═ca107380-28cb-11eb-146b-67cb40cfcfa2
# ╠═2e5b3fa2-28d1-11eb-3fab-ad91df79562e
# ╠═70c71b50-28c4-11eb-243d-e7fbf26c9d04
# ╠═76a2aaa0-28d1-11eb-111a-652bb440adc2
# ╠═8c283b3e-28c4-11eb-171f-9d4b01bb6082
# ╠═6b92194e-28c4-11eb-3775-ebcc7d10b249
