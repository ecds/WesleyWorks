# force update
GITHUB_ORG="ecds"
GITHUB_REPOSITORY="WesleyWorks-data"

# remove any old auto deploy
rm -rf autodeploy
# create an autodeploy folder
mkdir autodeploy

echo "Running app build ..."
ant
echo "Ran app build successfully"

echo "Fetching the data repository to build a data xar"
git clone https://github.com/$GITHUB_ORG/$GITHUB_REPOSITORY

cd $GITHUB_REPOSITORY && rm -rf build && mkdir build
echo "Running data build ..."
ant
echo "Ran data build successfully"

cd ..

# move the xar from build to autodeploy
mv build/*.xar autodeploy/
mv $GITHUB_REPOSITORY/build/*.xar autodeploy/

rm -rf $GITHUB_REPOSITORY

# GET the version of the project from the expath-pkg.xml
VERSION=$(cat expath-pkg.xml | grep package | grep version=  | awk -F'version="' '{ print $2 }' | awk -F'"' '{ print $1 }')
# GET the package name of the project from the expath-pkg.xml file
PACKAGE_NAME=$(cat expath-pkg.xml | grep package | grep version=  | awk -F'abbrev="' '{ print $2 }' | awk -F'"' '{ print tolower($1) }')

echo "Deploying app $PACKAGE_NAME:$VERSION"


echo "Building docker file"
docker build -t "$PACKAGE_NAME:$VERSION" --build-arg ADMIN_PASSWORD="$ADMIN_PASSWORD" .
echo docker build -t "$PACKAGE_NAME:$VERSION" --build-arg ADMIN_PASSWORD="$ADMIN_PASSWORD" .
echo "Built successfully"

echo "Starting Docker container"
echo "Open your browser to http://localhost:8080"
docker run -it -p 8080:8080 "$PACKAGE_NAME:$VERSION" > /dev/null 2>&1