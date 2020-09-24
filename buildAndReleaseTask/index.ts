import fs = require('fs');
import path = require('path');
import tl = require('azure-pipelines-task-lib/task');
import tr = require('azure-pipelines-task-lib/toolrunner');
const { v4: uuidv4 } = require('uuid');

async function run() {
    try {
        const sfUsername: string | undefined = tl.getInput('sfusername', true);
        if (sfUsername == '') {
            tl.setResult(tl.TaskResult.Failed, 'sfusername should not be empty');
            return;
        }
        console.log('Hello ', sfUsername);
        const sfPassword: string | undefined = tl.getInput('sfpassword', true);
        const securityToken: string | undefined = tl.getInput('sfsecuritytoken', false);
        const instanceUrl: string | undefined = tl.getInput('sfurl', false);
        const packageVersion: string | undefined = tl.getInput('appversion', true);
        const packageNamespace: string | undefined = tl.getInput('appnamespace', true);
        const isDebugOn: boolean | false = tl.getBoolInput('debug',false);
        
        tl.setResourcePath(path.join( __dirname, 'task.json'));

        let bashPath: string = tl.which('bash', true);
        let contents: string = "ls";
        let tempDirectory = tl.getVariable('agent.tempDirectory')!;
        tl.checkPath(tempDirectory, `${tempDirectory} (agent.tempDirectory)`);
        let fileName = uuidv4() + '.sh';
        let filePath = path.join(tempDirectory, fileName);
        contents = 'find . -name "*.sh" -exec chmod +x {} + \n ./deploy.sh -u "'+sfUsername+'" -p "'+sfPassword+'" -st "'+securityToken+'" -url "'+instanceUrl+'" -pns "'+packageNamespace+'" -v "'+packageVersion+'" -d "'+isDebugOn+'"';
        await fs.writeFileSync(
            filePath,
            contents,
            { encoding: 'utf8' });


        // Create the tool runner.
        console.log('========================== Starting Command Output ===========================');
        let bash = tl.tool(bashPath);
        bash.arg(filePath);

        let options = <tr.IExecOptions>{
            failOnStdErr: false,
            errStream: process.stdout, // Direct all output to STDOUT, otherwise the output may appear out
            outStream: process.stdout, // of order since Node buffers it's own STDOUT but not STDERR.
            ignoreReturnCode: true
        };

        // Listen for stderr.
        let stderrFailure = false;
        const aggregatedStderr: string[] = [];
        
            bash.on('stderr', (data: Buffer) => {
                stderrFailure = true;
                // Truncate to at most 10 error messages
                if (aggregatedStderr.length < 10) {
                    // Truncate to at most 1000 bytes
                    if (data.length > 1000) {
                        aggregatedStderr.push(`${data.toString('utf8', 0, 1000)}<truncated>`);
                    } else {
                        aggregatedStderr.push(data.toString('utf8'));
                    }
                } else if (aggregatedStderr.length === 10) {
                    aggregatedStderr.push('Additional writes to stderr truncated');
                }
            });
        

        // Run bash.
        let exitCode: number = await bash.exec(options);

        let result = tl.TaskResult.Succeeded;

        // Fail on exit code.
        if (exitCode !== 0) {
            tl.error(tl.loc('JS_ExitCode', exitCode));
            result = tl.TaskResult.Failed;
        }

        // Fail on stderr.
        if (stderrFailure) {
            tl.error(tl.loc('JS_Stderr'));
            aggregatedStderr.forEach((err: string) => {
                tl.error(err);
            });
            result = tl.TaskResult.Failed;
        }

        tl.setResult(result, '', true);
    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, "Unknown Exception:"+err.message);
    }
}

run();