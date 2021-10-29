## Micro-Frotend Deployment Methodology

First of all we should define simple rules.

- Every micro-frontend project should be initialised inside of the GitLab group called `Microfrontend`.

*This gives us the opportunity, in the deployer tool, to easily filter out only Micro-frontend projects.*

- Whenever there's a release candidate, which should be moved to the production,  it should be pushed on origin with the branch name starting with `version` and ending with the version number. *Examples are: `version1.0`, `version1.3`, `version2.0.3`*. From now on, when you'll see a *release candidate* in this document, it by definition will mean a a branch named just like in these examples.

*By obeying this rule, we can easily filter release candidates inside of the deploy tool.*

- Every branch, which is a release candidate, after a successful pipeline should be copied on the static server's corresponding folder.

Static server's file system should be configured like this:

- The root folder will be `microfrontend`
- Inside of `microfrontend` there will be multiple folders, containing folders with the same name of project's path in GitLab. 

*For example, if we have project called `VirtualSport` and it's path is `virtualsport`, it's release candidates will be copied to static's `microfrontend/virtualsport` folder.*

- Inside of project's folder, there will be folders for every release candidate, named just like branches, but instead of dots there will be hyphens.

*As an example, branch named `version1.0` will be inside of the folder `version1-0`*

- Production static server will also have folder named `microfrontend`, which will contain folders for each and every project inside of GitLab's group.
- Every micro-frontend application should be served from there.

## Functionality

With given rule-set, we can operate with these flows:

- Front-end Developers
	- Will be added to GitLab's MicroFrontend group
	- They can initialise separate micro-frontend projects, or work on existing ones inside this group.
	- Main flow will be just like on Adjarabet, but whenever there's a release candidate, they'll make a new branch according to the rules. *We might even give this responsibility to product owners*
- Deployer Tool
	- Filters only Micro-Frontend projects from GitLab and gives it's user an option to choose these projects from the dropdown.
	- Whenever project is selected, will draw a dropdown, containing every release candidate from this project.
	- Whenever the user presses the deploy button, it will instantly update it on the production.
- Backend
	- Deployer backend should have one additional `PUT` request, which will fire deployer script on the server.
	- Script should accept two parameters, `name` and `version`.
	- Whenever script fires, it will copy files from `microfrontend/*name*/*version*` folder to production static server's `microfrontend/*name*` folder.
