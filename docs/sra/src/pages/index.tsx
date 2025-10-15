import Layout from '@theme/Layout';
import { JSX } from 'react';
import Button from '../components/Button';


const Hero = () => {
  return (
    <div className="px-4 md:px-10 min-h-screen flex flex-col justify-center items-center w-full">
      {/* Logo & Title Section */}
      <div className="relative w-full flex flex-col items-center">
        <div className="flex flex-row items-center justify-center w-full max-w-3xl relative z-10">
          {/* Logo Left */}
          <div className="flex-shrink-0 mr-6">
            <img src="img/primary-icon-orange-cloud-security.svg" alt="SRA Logo" className="w-40 md:w-48" />
          </div>
          {/* Title Right */}
          <h1 className="text-4xl md:text-5xl font-bold text-left mb-0">
            <span>Security Reference Architecture (SRA) - </span>
            <span className="block">Terraform Templates</span>
          </h1>
        </div>
      </div>

      {/* Provided by */}
      {/* <p className="text-center text-gray-600 dark:text-gray-500 mt-4 mb-2">
        Provided by <a href="https://github.com/databricks-industry-solutions" className="underline text-blue-500 hover:text-blue-700">Databricks Industry Solutions</a>
      </p> */}

      {/* Description */}
      <p className="text-lg text-center text-balance mb-8">
      The Security Reference Architecture (SRA) with Terraform enables deployment of Databricks workspaces and cloud infrastructure configured with security best practices.
      </p>

      {/* Call to Action Buttons */}
      <div className="mt-6 flex flex-col space-y-4 md:flex-row md:space-y-0 md:space-x-4">
        <Button
          variant="secondary"
          outline={true}
          link="/docs/overview"
          size="large"
          label={"Overview"}
          className="w-full md:w-auto"
        />
        <Button
          variant="secondary"
          outline={true}
          link="/docs/usage/AWS"
          size="large"
          label={"AWS"}
          className="w-full md:w-auto"
        />
        <Button
          variant="secondary"
          outline={true}
          link="/docs/usage/Azure"
          size="large"
          label={"Azure"}
          className="w-full md:w-auto"
        />
        <Button
          variant="secondary"
          outline={true}
          link="/docs/usage/GCP"
          size="large"
          label={"GCP"}
          className="w-full md:w-auto"
        />
        <Button
          variant="secondary"
          outline={true}
          link="/docs/additionalresources"
          size="large"
          label={"Additional Resources"}
          className="w-full md:w-auto"
        />
        {/* <Button
          variant="secondary"
          outline={true}
          link="/docs/troubleshooting"
          size="large"
          label={"Troubleshooting"}
          className="w-full md:w-auto"
        /> */}
      </div>
    </div>
  );
};



export default function Home(): JSX.Element {
  return (
    <Layout>
      <main>
        <div className='flex justify-center mx-auto'>
          <div className='max-w-screen-lg'>
            <Hero />
          </div>
        </div>
      </main>
    </Layout>
  );
}