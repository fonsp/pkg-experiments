### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 52305f60-2380-11eb-0a3b-6f693199061f
using Test

# ╔═╡ 6235feb0-28cb-11eb-1754-8fc9b563ce19
using UUIDs

# ╔═╡ 6a921012-2382-11eb-1e80-7fa5613b33fe
import Pkg

# ╔═╡ f2e4721a-3ccc-11eb-2ad0-21fd855113e7


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
choice = "Revise"

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

# ╔═╡ c4eed44e-3cc8-11eb-316b-97884e463718
md"""
## Recommended version ranges
"""

# ╔═╡ d4346da4-3cca-11eb-15a8-f9e2b48b5708
Pkg.Types.VersionRange("3-9.0")

# ╔═╡ e43b4808-3cca-11eb-3cf3-972d7d175fd4


# ╔═╡ af0e4e4c-3cc9-11eb-2fdf-c983863e718f
import Pkg.Types: VersionRange, VersionBound

# ╔═╡ a56422e4-3cca-11eb-0da6-951da09b1464
methods(VersionBound)

# ╔═╡ 729f84e8-3cca-11eb-1126-a116ff515c20
v"0.1.1" ∈ VersionRange(v"0.1")

# ╔═╡ 2cdf88fa-3cc9-11eb-2c67-9582b4a9f20d
function recommended_ranges(available::AbstractVector{VersionNumber})
	unique(
		if v.major == 0
			VersionRange("0.$(v.minor)")
		else
			VersionRange("$(v.major)")
		end
	for v in available) |> reverse!
end

# ╔═╡ 6d4d550a-3ccb-11eb-3374-b99b070a870c
@test recommended_ranges([
		v"0.2.0", v"0.2.1", v"1.0.3", v"1.1.0", v"1.1.1", v"2.0.0", v"2.0.7", v"2.1.0", v"3.1.9"
		]) == [
	VersionRange("3"), VersionRange("2"), VersionRange("1"), VersionRange("0.2")
]


# ╔═╡ a5e73ffc-3ccb-11eb-1d27-df73a6704352


# ╔═╡ 578dce4c-3cca-11eb-2472-e1a3770a555d
v = v"1.2.3"

# ╔═╡ 5afe7290-3cca-11eb-1098-1d6d2f289d63
v.major == 1

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

# ╔═╡ f6d961e4-3cc9-11eb-008f-2fb676ec514b
recommended_ranges(choice_versions)

# ╔═╡ e2100f0e-3ccb-11eb-1b04-ed78ad5b2648
string(choice_versions) |> Text

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
md"""
This next test might fail if you're running the notebook, it's meant more for the CI which initializes the environment from the Manifest.toml in this repo
"""

# ╔═╡ 70c71b50-28c4-11eb-243d-e7fbf26c9d04
@test is_downloaded("PlutoUI", v"0.6.5")

# ╔═╡ 76a2aaa0-28d1-11eb-111a-652bb440adc2
@test !is_downloaded("PlutoUI", v"0.6.4")

# ╔═╡ 8c283b3e-28c4-11eb-171f-9d4b01bb6082


# ╔═╡ e6a6d290-28e0-11eb-04c4-8d6fae877837
md"""
# Serializing the Pkg state
"""

# ╔═╡ ebaef830-28e0-11eb-3051-4143c9b2b0a7
project = [
	(name="a", rev="safdf", version=v"1.2.3"),
	(name="c", version=v"1.2.3"),
	(name="b", path="/a/b/c"),
	]

# ╔═╡ 47a0912e-28e1-11eb-0fdf-59e89fa0f627
serialize_project(project::Vector{<:NamedTuple}) = sprint(serialize_project, project)

# ╔═╡ 731f7cb2-28e4-11eb-1854-612a0f69825f


# ╔═╡ 01edc8e0-28e3-11eb-1d8e-9322c2e0807f
safe_pkg_vect(::Any) = false

# ╔═╡ 0c9bb3b0-28e3-11eb-07aa-8753d31b0c4a
function safe_pkg_entry_field_value(e::Expr)
	e.head == :macrocall && length(e.args) == 3 && (
		e.args[1] == Symbol("@v_str") &&
		e.args[2] isa LineNumberNode &&
		e.args[3] isa String
		)
end

# ╔═╡ 766bde00-28e3-11eb-2391-59ea053b1434
safe_pkg_entry_field_value(::String) = true

# ╔═╡ 1488d0d0-28e3-11eb-3871-518d213c2686
safe_pkg_entry_field_value(::Any) = false

# ╔═╡ bb0eee8e-28e2-11eb-16dd-85d891b873fe
function safe_pkg_vect(e::Expr)
	e.head == :vect &&
	all(e.args) do a
		a isa Expr && a.head == :tuple && all(a.args) do f
			f isa Expr && f.head == :(=) && length(f.args) == 2 && (
					f.args[1] isa Symbol &&
					safe_pkg_entry_field_value(f.args[2])
				)
		end
	end
end

# ╔═╡ 30197720-28e1-11eb-37dd-3362c847d757
function deserialize_project(str::String, start::Integer)::Vector{<:NamedTuple}
	expr = Meta.parse(str, start; raise=false)[1]
	@assert safe_pkg_vect(expr.args[2])
	Core.eval(Main, expr.args[2])
end

# ╔═╡ 75d25290-28e2-11eb-3d80-158fc7b4a449
Dump(x) = sprint() do io
	dump(io, x; maxdepth=99999)
end |> Text

# ╔═╡ 341ed4a2-3cc9-11eb-3e61-63bdc8348bc7
Pkg.Types.VersionRange("3-9") |> Dump

# ╔═╡ c37cbf52-3cca-11eb-0145-db6151f8d7b7
Pkg.Types.VersionRange("3-9.0") |> Dump

# ╔═╡ c95fb7c0-28e4-11eb-1b4b-8f91caacf14b
variable_name = "PLUTO_NOTEBOOK_PACKAGES"

# ╔═╡ 10e35a60-28e1-11eb-10d7-7bd2db5bc866
function serialize_project(io::IO, project::Vector{<:NamedTuple})
	if isempty(project)
		write(io, variable_name, " = []")
	else
		write(io, variable_name, " = [\n")
		for p in project
			print(io, "\t", p, ",\n")
		end
		write(io, "]\n")
	end
end

# ╔═╡ 4588d4c0-28e1-11eb-2ee8-870608ba8cec
serialize_project(project) |> Text

# ╔═╡ 9cad6310-28e6-11eb-2494-53c3b8056ad2
serialize_project(NamedTuple[]) |> Text

# ╔═╡ 95388000-28e2-11eb-3f73-bd7700b87946
e = deserialize_project(serialize_project(project), 1)

# ╔═╡ 9a2ea440-28e2-11eb-0a59-fd11997c6206
safe_pkg_vect(e)

# ╔═╡ f9a07fd0-28e1-11eb-1839-75520ad7d3f4
test_header = """
# Blasjflkjas
#asfdsf 



asdfasd
f

sfd

$(serialize_project(project))

asdf

firs
sdfff

"""

# ╔═╡ 6b92194e-28c4-11eb-3775-ebcc7d10b249
function deserialize_project_auto(str::String)::Vector{<:NamedTuple}
	i = findfirst(variable_name, str)
	deserialize_project(str, first(i))
end

# ╔═╡ 72bf6d40-28e2-11eb-3a13-c334b81603f9
deserialize_project_auto(serialize_project(project)) |> Dump

# ╔═╡ ee721a5e-28e1-11eb-232c-4303c5f9b01d
@test deserialize_project_auto(serialize_project(project)) == project

# ╔═╡ 0d26cac0-28e5-11eb-1bb8-052af64ffb80
@test deserialize_project_auto(test_header) == project

# ╔═╡ Cell order:
# ╠═52305f60-2380-11eb-0a3b-6f693199061f
# ╠═6a921012-2382-11eb-1e80-7fa5613b33fe
# ╠═f2e4721a-3ccc-11eb-2ad0-21fd855113e7
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
# ╟─c4eed44e-3cc8-11eb-316b-97884e463718
# ╠═341ed4a2-3cc9-11eb-3e61-63bdc8348bc7
# ╠═c37cbf52-3cca-11eb-0145-db6151f8d7b7
# ╠═d4346da4-3cca-11eb-15a8-f9e2b48b5708
# ╠═a56422e4-3cca-11eb-0da6-951da09b1464
# ╠═e43b4808-3cca-11eb-3cf3-972d7d175fd4
# ╠═729f84e8-3cca-11eb-1126-a116ff515c20
# ╠═af0e4e4c-3cc9-11eb-2fdf-c983863e718f
# ╠═2cdf88fa-3cc9-11eb-2c67-9582b4a9f20d
# ╠═f6d961e4-3cc9-11eb-008f-2fb676ec514b
# ╠═e2100f0e-3ccb-11eb-1b04-ed78ad5b2648
# ╠═6d4d550a-3ccb-11eb-3374-b99b070a870c
# ╠═a5e73ffc-3ccb-11eb-1d27-df73a6704352
# ╠═578dce4c-3cca-11eb-2472-e1a3770a555d
# ╠═5afe7290-3cca-11eb-1098-1d6d2f289d63
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
# ╟─2e5b3fa2-28d1-11eb-3fab-ad91df79562e
# ╠═70c71b50-28c4-11eb-243d-e7fbf26c9d04
# ╠═76a2aaa0-28d1-11eb-111a-652bb440adc2
# ╠═8c283b3e-28c4-11eb-171f-9d4b01bb6082
# ╟─e6a6d290-28e0-11eb-04c4-8d6fae877837
# ╠═ebaef830-28e0-11eb-3051-4143c9b2b0a7
# ╠═10e35a60-28e1-11eb-10d7-7bd2db5bc866
# ╠═47a0912e-28e1-11eb-0fdf-59e89fa0f627
# ╠═30197720-28e1-11eb-37dd-3362c847d757
# ╠═731f7cb2-28e4-11eb-1854-612a0f69825f
# ╠═4588d4c0-28e1-11eb-2ee8-870608ba8cec
# ╠═9cad6310-28e6-11eb-2494-53c3b8056ad2
# ╠═95388000-28e2-11eb-3f73-bd7700b87946
# ╠═9a2ea440-28e2-11eb-0a59-fd11997c6206
# ╠═bb0eee8e-28e2-11eb-16dd-85d891b873fe
# ╠═01edc8e0-28e3-11eb-1d8e-9322c2e0807f
# ╠═0c9bb3b0-28e3-11eb-07aa-8753d31b0c4a
# ╠═766bde00-28e3-11eb-2391-59ea053b1434
# ╠═1488d0d0-28e3-11eb-3871-518d213c2686
# ╠═72bf6d40-28e2-11eb-3a13-c334b81603f9
# ╠═ee721a5e-28e1-11eb-232c-4303c5f9b01d
# ╠═75d25290-28e2-11eb-3d80-158fc7b4a449
# ╠═c95fb7c0-28e4-11eb-1b4b-8f91caacf14b
# ╠═f9a07fd0-28e1-11eb-1839-75520ad7d3f4
# ╠═6b92194e-28c4-11eb-3775-ebcc7d10b249
# ╠═0d26cac0-28e5-11eb-1bb8-052af64ffb80
