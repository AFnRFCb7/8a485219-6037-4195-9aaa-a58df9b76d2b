{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    { input ? x : x , output ? x : x } :
                        let
                            implementation =
                                { lib , pkgs , ... } @module :
                                    let
                                        identified =
                                            if builtins.typeOf input == "lambda" then input module
                                            else if builtins.typeOf input == "null" then module
                                            else builtins.throw "0823171356089193" ;
                                        in
                                            with identified ;
                                                {
                                                    options =
                                                        {
                                                            lazy-node-application =
                                                                lib.mkOption
                                                                    {
                                                                        default =
                                                                            {
                                                                                code ,
                                                                                dependencies ,
                                                                                entry-point ,
                                                                                mounts ,
                                                                                name ,
                                                                                nodejs ,
                                                                                post ,
                                                                                variables
                                                                            } :
                                                                                config.lazy-shell-application
                                                                                    {
                                                                                        mounts =
                                                                                            {
                                                                                                "work" = { temporary = { type = "temporary" ; } ; } ;
                                                                                            } // lib.mapAttrs' ( name : value : { name = "application/${ name }" ; value = value ; } ) mounts ;
                                                                                        name = name ;
                                                                                        post = post ;
                                                                                        runtime-inputs =
                                                                                            { pkgs , ... } @module :
                                                                                                builtins.concatLists
                                                                                                    [
                                                                                                        [ pkgs.coreutils ]
                                                                                                        ( nodejs module ) ( code module )
                                                                                                        (
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "dependencies" ;
                                                                                                                    runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            mkdir --parents node_modules
                                                                                                                            ${ builtins.concatStringsSep "\n" ( builtins.map ( dependency : ''ln --symbolic ${ dependency } /mounts/work/node_modules'' ) ( dependencies module ) ) }
                                                                                                                        '' ;
                                                                                                                }
                                                                                                        )
                                                                                                    ] ;
                                                                                        text =
                                                                                            ''
                                                                                                mkdir --parents /mounts/work/node_modules

                                                                                                cd /mounts/work
                                                                                                dependencies
                                                                                                code
                                                                                                exec node "${ entry_point }" "$@"
                                                                                            '' ;
                                                                                        variables = variables ;
                                                                                    } ;
                                                                        type = lib.types.functionTo lib.types.package ;
                                                                    } ;
                                                        } ;
                                                } ;
                            in
                                {
                                    checks = null ;
                                    implementation =
                                        if builtins.typeOf output == "lambda" then output implementation
                                        else if builtins.typeOf output == "null" then implementation
                                        else builtins.throw "8568698534705300" ;
                                    imports = [ ] ;
                                } ;
            } ;
}